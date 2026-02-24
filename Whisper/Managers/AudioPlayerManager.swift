import AVFoundation
import Foundation

final class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()

    // MARK: - Properties

    /// 总音量（0.0 ~ 1.0），作用于所有声音
    @Published var masterVolume: Double = 1.0 {
        didSet {
            refreshAllVolumes()
        }
    }

    private var audioSessionConfigured = false
    private var players: [UUID: AVPlayer] = [:]
    private var baseVolumes: [UUID: Double] = [:]
    private var loopObservers: [UUID: NSObjectProtocol] = [:]

    private var fadeTimer: Timer?
    private var fadeStartDate: Date?
    private var fadeEndDate: Date?

    // MARK: - Constants

    private enum Constants {
        static let fadeTickInterval: TimeInterval = 0.1
        static let minimumVolume: Float = 0.0
        static let maximumVolume: Float = 1.0
        static let seekTolerance: CMTime = .zero
    }

    private init() {}

    deinit {
        cleanup()
    }

    // MARK: - Public Methods

    /// 更新声音播放状态
    func update(sound: Sound) {
        if sound.isPlaying {
            startPlaying(sound)
        } else {
            stopPlaying(sound)
        }
    }

    /// 更新指定声音的音量
    func updateVolume(for sound: Sound) {
        guard let player = players[sound.id] else { return }
        baseVolumes[sound.id] = sound.volume
        player.volume = calculateVolume(baseVolume: sound.volume)
    }

    /// 刷新所有播放器的音量（总音量或淡出变化时调用）
    private func refreshAllVolumes() {
        for (id, player) in players {
            let base = baseVolumes[id] ?? 1.0
            player.volume = calculateVolume(baseVolume: base)
        }
    }

    /// 停止所有播放
    func stopAll() {
        for (_, player) in players { //id
            player.pause()
            player.replaceCurrentItem(with: nil)
        }

        removeAllObservers()
        players.removeAll()
        baseVolumes.removeAll()
        cancelFadeOut()
    }

    /// 开始淡出效果
    /// - Parameters:
    ///   - totalDuration: 总时长
    ///   - fadeDuration: 淡出时长
    func startFadeOut(totalDuration: TimeInterval, fadeDuration: TimeInterval) {
        guard fadeDuration > 0, totalDuration >= fadeDuration else {
            print("[AudioPlayerManager] Invalid fade parameters")
            return
        }

        fadeTimer?.invalidate()

        let fadeStartTime = Date().addingTimeInterval(totalDuration - fadeDuration)
        fadeStartDate = fadeStartTime
        fadeEndDate = fadeStartTime.addingTimeInterval(fadeDuration)

        fadeTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.fadeTickInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateFadeProgress()
        }
    }

    /// 取消淡出效果
    func cancelFadeOut() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        fadeStartDate = nil
        fadeEndDate = nil
        applyFadeMultiplier(1.0)
    }

    // MARK: - Private Methods

    private func startPlaying(_ sound: Sound) {
        // 防止重复创建
        guard players[sound.id] == nil else { return }

        configureAudioSessionIfNeeded()

        guard let url = validateAndGetURL(from: sound.url) else {
            print("[AudioPlayerManager] Invalid URL: \(sound.url)")
            return
        }

        let player = createPlayer(with: url, volume: sound.volume)
        setupLoopObserver(for: sound.id, player: player)

        player.play()
        players[sound.id] = player
        baseVolumes[sound.id] = sound.volume
    }

    private func stopPlaying(_ sound: Sound) {
        guard let player = players[sound.id] else { return }

        player.pause()
        player.replaceCurrentItem(with: nil)
        players.removeValue(forKey: sound.id)
        baseVolumes.removeValue(forKey: sound.id)

        removeObserver(for: sound.id)
    }

    private func createPlayer(with url: URL, volume: Double) -> AVPlayer {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.volume = calculateVolume(baseVolume: volume)
        return player
    }

    private func setupLoopObserver(for id: UUID, player: AVPlayer) {
        guard let item = player.currentItem else { return }

        let observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            player?.play()
        }

        loopObservers[id] = observer
    }

    private func removeObserver(for id: UUID) {
        if let observer = loopObservers[id] {
            NotificationCenter.default.removeObserver(observer)
            loopObservers.removeValue(forKey: id)
        }
    }

    private func removeAllObservers() {
        for observer in loopObservers.values {
            NotificationCenter.default.removeObserver(observer)
        }
        loopObservers.removeAll()
    }

    private func validateAndGetURL(from urlString: String) -> URL? {
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              scheme == "http" || scheme == "https"
        else {
            return nil
        }
        return url
    }

    // MARK: - Audio Session

    private func configureAudioSessionIfNeeded() {
        guard !audioSessionConfigured else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try session.setActive(true)
            audioSessionConfigured = true
        } catch {
            print("[AudioPlayerManager] Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Fade Logic

    private func updateFadeProgress() {
        guard let start = fadeStartDate, let end = fadeEndDate else { return }

        let now = Date()

        // 淡出结束
        if now >= end {
            applyFadeMultiplier(0.0)
            stopAll()
            cancelFadeOut()
            return
        }

        // 淡出未开始
        guard now > start else {
            applyFadeMultiplier(1.0)
            return
        }

        // 计算淡出进度
        let totalDuration = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        let progress = elapsed / totalDuration
        let multiplier = max(0.0, 1.0 - progress)

        applyFadeMultiplier(multiplier)
    }

    private func calculateFadeMultiplier() -> Double {
        guard let start = fadeStartDate, let end = fadeEndDate else {
            return 1.0
        }

        let now = Date()

        if now <= start { return 1.0 }
        if now >= end { return 0.0 }

        let totalDuration = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        let progress = elapsed / totalDuration

        return max(0.0, 1.0 - progress)
    }

    private func applyFadeMultiplier(_ multiplier: Double) {
        for (id, player) in players {
            let baseVolume = baseVolumes[id] ?? 1.0
            player.volume = Float(baseVolume * masterVolume * multiplier)
        }
    }

    private func calculateVolume(baseVolume: Double) -> Float {
        let fadeMultiplier = calculateFadeMultiplier()
        let volume = baseVolume * masterVolume * fadeMultiplier
        return Float(max(0.0, min(1.0, volume)))
    }

    // MARK: - Cleanup

    private func cleanup() {
        stopAll()

        if audioSessionConfigured {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
}
