//
//  WhiteNoiseEngine.swift
//  WhiteNoisePlayer
//

@preconcurrency import AVFoundation
import Combine

// 移除 @MainActor —— 类本身不绑定主线程
// UI 状态通过 @MainActor @Published 精准发布
final class WhiteNoiseEngine: ObservableObject, @unchecked Sendable {
    static let shared = WhiteNoiseEngine()
    static let maxConcurrentTracks = 6

    // MARK: - UI 状态（只在 MainActor 读写）

    @MainActor @Published private(set) var tracks: [String: AudioTrack] = [:] {
        didSet {
            updateNowPlaying()
        }
    }
    @MainActor @Published private(set) var state: EngineState = .idle {
        didSet {
            updateNowPlaying()
        }
    }

    // 用于记录最近播放的声音名称，供 Now Playing 显示
    @MainActor private var lastPlayingSoundName: String?
    @MainActor private var currentMixName: String? // ← 用户从混合库播放时设置

    // MARK: - 音频硬件（只在 audioQueue 访问）

    private let engine = AVAudioEngine()
    private var players: [String: AVAudioPlayerNode] = [:]
    private var audioFiles: [String: AVAudioFile] = [:]

    // 所有音频操作的专用串行队列
    // 串行保证 players / audioFiles / fadeTasks 无需额外锁
    private let audioQueue = DispatchQueue(
        label: "com.whitenoise.audioQueue",
        qos: .userInitiated
    )

    // MARK: - Fade 控制（只在 audioQueue 访问）

    // 用 Task 替代 Timer，可取消、可 await、不占线程
    private var fadeTasks: [String: Task<Void, Never>] = [:]

    // MARK: - 业务依赖

    private let cache = AudioCache()
    private let loader = NetworkLoader()
    private let session = AudioSessionManager()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    private init() {
        session.configure()
        observeInterruptions()
        observeRouteChanges()
        setupNowPlayingCommands()
    }

    private func setupNowPlayingCommands() {
        NowPlayingManager.shared.setupRemoteCommands(
            playHandler: { [weak self] in self?.resumeAll() },
            pauseHandler: { [weak self] in self?.pauseAll() },
            toggleHandler: { [weak self] in
                guard let self else { return }
                // state 是 @MainActor，需切到主线程读取
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if self.state == .playing {
                        self.pauseAll()
                    } else {
                        self.resumeAll()
                    }
                }
            }
        )
    }

    private func updateNowPlaying() {
        Task { @MainActor in
            guard !tracks.isEmpty else {
                NowPlayingManager.shared.clearNowPlaying()
                return
            }

            let title: String

            if let mixName = currentMixName {
                // ✅ 用户从混合库播放，显示混合名称
                title = mixName
            } else if tracks.count == 1 {
                // 单轨，显示声音名称
                title = tracks.values.first?.displayName ?? lastPlayingSoundName ?? "White Noise"
            } else {
                // 多轨但不是从混合库播放（用户手动叠加），显示包含的所有声音名称
                title = tracks.values
                    .sorted { $0.displayName < $1.displayName }
                    .map(\.displayName)
                    .joined(separator: "、")
            }

            let artworkName = tracks.values
                .sorted { $0.displayName < $1.displayName }
                .compactMap(\.artworkName)
                .first

            NowPlayingManager.shared.updateNowPlaying(
                title: title,
                isPlaying: state == .playing,
                artworkName: artworkName
            )
        }
    }

    // MARK: - Public API

    /// 从混合库播放：先停止当前所有轨道，再批量加载，显示混合名称
    func applyMix(items: [(soundID: String, volume: Float, url: URL, name: String)],
                  mixName: String) async throws
    {
        // 设置混合名称（主线程）
        await MainActor.run {
            self.currentMixName = mixName
            self.lastPlayingSoundName = nil // 清除单轨名称，避免干扰
        }

        // 停止当前播放，但保留混合名称给 Now Playing 使用
        stopAll(clearNames: false)

        // 并发加载所有轨道
        try await withThrowingTaskGroup(of: Void.self) { group in
            for item in items {
                group.addTask {
                    try await self.playInternal(
                        url: item.url,
                        id: item.soundID,
                        volume: item.volume,
                        name: item.name
                    )
                }
            }
            try await group.waitForAll()
        }
    }

    func play(url: URL, id: String, volume: Float = 1.0, name: String? = nil) async throws {
        await MainActor.run {
            if let name { self.lastPlayingSoundName = name }
            self.currentMixName = nil
        }
        try await playInternal(url: url, id: id, volume: volume, name: name)
    }

    private func playInternal(url: URL, id: String, volume: Float = 1.0, name: String? = nil) async throws {
        await MainActor.run {
            if let name { self.lastPlayingSoundName = name }
        }

        let (trackCount, hasExisting) = await MainActor.run {
            (tracks.count, tracks[id] != nil)
        }

        guard hasExisting || trackCount < Self.maxConcurrentTracks else {
            throw EngineError.tooManyTracks(limit: Self.maxConcurrentTracks)
        }

        await MainActor.run { state = .loading }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task.detached(priority: .userInitiated) { [weak self] in
                guard let self else {
                    continuation.resume(throwing: EngineError.engineDeallocated)
                    return
                }
                do {
                    // ✅ fetch 和 AVAudioFile 都在非主线程
                    let fileURL = try await self.loader.fetch(url: url, cache: self.cache)
                    let audioFile = try AVAudioFile(forReading: fileURL)

                    // ✅ 硬件操作切回 audioQueue
                    self.audioQueue.async { [weak self] in
                        guard let self else {
                            continuation.resume(throwing: EngineError.engineDeallocated)
                            return
                        }
                        do {
                            self.cancelFade(id: id)
                            self.attachPlayer(id: id, audioFile: audioFile, volume: volume)
                            try self.startEngineIfNeeded()
                            self.players[id]?.play()
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        // ✅ 只有这里回主线程，极快
        await MainActor.run { [weak self] in
            guard let self, let player = self.players[id] else { return }
            let track = AudioTrack(id: id, player: player, volume: volume, displayName: name, artworkName: id)
            self.tracks[id] = track
            self.state = .playing
        }
    }

    /// 移除轨道，先淡出再卸载
    func remove(id: String, fadeDuration: TimeInterval = 1.0) {
        // 立即从 UI 层面移除，让界面响应迅速
        Task { @MainActor in
            guard tracks[id] != nil else { return }
            tracks.removeValue(forKey: id)
            if tracks.isEmpty { state = .idle
                lastPlayingSoundName = nil
                currentMixName = nil
            }
        }

        // 音频层：淡出后卸载（在 audioQueue 串行执行）
        audioQueue.async { [weak self] in
            guard let self, self.players[id] != nil else { return }

            // 取消已有淡变（比如之前有 setVolume 正在进行）
            self.cancelFade(id: id)

            // 启动淡出 Task，完成后 detach
            self.fadeTasks[id] = Task { [weak self] in
                guard let self else { return }

                await self.runFade(id: id, to: 0, duration: fadeDuration)

                // 淡出完成，回到 audioQueue 卸载
                self.audioQueue.async { [weak self] in
                    guard let self else { return }
                    // 确认这段时间内 player 没有被新的 play() 替换
                    self.detachPlayer(id: id)
                    self.fadeTasks.removeValue(forKey: id)
                }
            }
        }
    }

    /// 调整单轨音量（带淡变）
    func setVolume(_ volume: Float, for id: String, fade: TimeInterval = 0.3) {
        audioQueue.async { [weak self] in
            guard let self, self.players[id] != nil else { return }
            self.cancelFade(id: id)
            self.fadeTasks[id] = Task { [weak self] in
                guard let self else { return }
                await self.runFade(id: id, to: volume, duration: fade)
                self.audioQueue.async { [weak self] in
                    self?.fadeTasks.removeValue(forKey: id)
                }
            }
        }
    }

    /// 调整主音量（影响所有轨道）
    func setMasterVolume(_ volume: Float) {
        audioQueue.async { [weak self] in
            self?.engine.mainMixerNode.outputVolume = max(0, min(1, volume))
        }
    }

    func pauseAll() {
        audioQueue.async { [weak self] in
            guard let self else { return }
            self.players.values.forEach { $0.pause() }
            Task { await self.setStateOnMain(.paused) }
        }
    }

    func resumeAll() {
        audioQueue.async { [weak self] in
            guard let self, !self.players.isEmpty else { return } // ← 加 guard
            do {
                try self.startEngineIfNeeded()
                self.players.values.forEach { $0.play() }
                Task { await self.setStateOnMain(.playing) }
            } catch {
                print("[WhiteNoiseEngine] resumeAll 失败: \(error)")
            }
        }
    }

    func stopAll() {
        stopAll(clearNames: true)
    }

    private func stopAll(clearNames: Bool) {
        // UI 先清空
        Task { @MainActor in
            tracks.removeAll()
            state = .idle
            if clearNames {
                lastPlayingSoundName = nil
                currentMixName = nil
            }
        }
        // 音频资源异步清理
        audioQueue.async { [weak self] in
            guard let self else { return }
            self.fadeTasks.values.forEach { $0.cancel() }
            self.fadeTasks.removeAll()
            self.resetEngine()
        }
    }

    // MARK: - 音频硬件私有方法（只在 audioQueue 调用）

    @discardableResult
    private func attachPlayer(id: String, audioFile: AVAudioFile, volume: Float) -> AVAudioPlayerNode {
        // 如果已有同 id 的 player，先完整卸载
        if players[id] != nil { detachPlayer(id: id) }

        let player = AVAudioPlayerNode()
        player.volume = volume
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFile.processingFormat)
        players[id] = player
        audioFiles[id] = audioFile

        scheduleLoop(player: player, audioFile: audioFile, id: id)
        return player
    }

    /// 无缝循环调度：文件播完前自动重新调度，磁盘流式读取，内存极低
    private func scheduleLoop(player: AVAudioPlayerNode, audioFile: AVAudioFile, id: String) {
        audioFile.framePosition = 0

        player.scheduleFile(audioFile, at: nil, completionCallbackType: .dataConsumed) { [weak self] _ in
            // 回调线程不确定，切回 audioQueue 访问共享状态
            self?.audioQueue.async { [weak self] in
                guard let self,
                      self.players[id] === player, // player 未被替换
                      player.isPlaying // 未被暂停/停止
                else { return }
                self.scheduleLoop(player: player, audioFile: audioFile, id: id)
            }
        }
    }

    private func detachPlayer(id: String) {
        // cancelFade 必须先于 player.stop()，避免淡变 Task 在 stop 后继续写 volume
        cancelFade(id: id)

        guard let player = players[id] else { return }
        audioFiles.removeValue(forKey: id)
        player.stop()
        engine.disconnectNodeOutput(player)
        engine.detach(player)
        players.removeValue(forKey: id)
    }

    private func startEngineIfNeeded() throws {
        try session.activateForPlayback()
        guard !engine.isRunning else { return }
        try engine.start()
    }

    private func resetEngine() {
        players.values.forEach { $0.stop() }
        audioFiles.removeAll()
        for player in players.values {
            engine.disconnectNodeOutput(player)
            engine.detach(player)
        }
        players.removeAll()
        engine.stop()
    }

    // MARK: - Fade 私有方法（在 audioQueue 发起，Task 内跨线程执行）

    /// 取消指定轨道的淡变 Task（在 audioQueue 调用）
    private func cancelFade(id: String) {
        fadeTasks[id]?.cancel()
        fadeTasks.removeValue(forKey: id)
    }

    /// 对数曲线音量渐变，替代原来的 Timer 方案
    /// - 在 Task 内用 Task.sleep 等待，不阻塞任何线程
    /// - 硬件音量直接写（AVAudioPlayerNode.volume 是线程安全的）
    /// - UI 音量通过 MainActor.run 精准切回主线程
    private func runFade(id: String, to target: Float, duration: TimeInterval) async {
        guard let player = players[id] else { return }

        let startVolume = player.volume
        let clampedTarget = max(0, min(1, target))

        // 时长为 0 或音量相同，直接设置
        guard duration > 0, abs(startVolume - clampedTarget) > 0.0001 else {
            player.volume = clampedTarget
            await MainActor.run { [weak self] in
                self?.tracks[id]?.applyUIVolume(clampedTarget)
            }
            return
        }

        // 对数插值（感知音量更线性）
        let startDB = 20 * log10(max(0.0001, startVolume))
        let targetDB = 20 * log10(max(0.0001, clampedTarget))

        let steps = max(30, Int(duration * 60))
        let interval = UInt64(duration / Double(steps) * 1_000_000_000) // 纳秒

        for step in 1 ... steps {
            guard !Task.isCancelled else { return }

            let t = Float(step) / Float(steps)
            let currentDB = startDB + (targetDB - startDB) * t
            // 最后一步精确对齐目标值，消除浮点误差
            let newVolume = (step == steps) ? clampedTarget : pow(10, currentDB / 20)

            // 硬件音量：AVAudioPlayerNode.volume 线程安全，直接写
            player.volume = newVolume

            // UI 音量：切到主线程
            let v = newVolume
            await MainActor.run { [weak self] in
                self?.tracks[id]?.applyUIVolume(v)
            }

            if step < steps {
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }

    // MARK: - 主线程状态工具

    @MainActor
    private func setStateOnMain(_ newState: EngineState) {
        state = newState
    }

    // MARK: - 系统通知

    private func observeInterruptions() {
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: audioQueue) // 音频处理不需要主线程
            .sink { [weak self] in self?.handleInterruption($0) }
            .store(in: &cancellables)
    }

    private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            pauseAll()
        case .ended:
            let options = AVAudioSession.InterruptionOptions(
                rawValue: info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            )
            if options.contains(.shouldResume) { resumeAll() }
        @unknown default:
            break
        }
    }

    private func observeRouteChanges() {
        NotificationCenter.default
            .publisher(for: AVAudioSession.routeChangeNotification)
            .receive(on: audioQueue)
            .sink { [weak self] in self?.handleRouteChange($0) }
            .store(in: &cancellables)
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue),
              reason == .oldDeviceUnavailable else { return }
        pauseAll()
    }
}

// MARK: - EngineState

enum EngineState {
    case idle // 无轨道
    case loading // 正在加载
    case playing // 播放中
    case paused // 已暂停
}

enum EngineError: LocalizedError {
    case tooManyTracks(limit: Int)
    case engineDeallocated

    var errorDescription: String? {
        switch self {
        case let .tooManyTracks(limit):
            return "最多同时播放 \(limit) 个声音，请先关闭一些声音。"
        case .engineDeallocated:
            return "音频引擎已释放。"
        }
    }
}
