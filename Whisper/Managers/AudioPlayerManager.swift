//
//  AudioPlayerManager.swift
//  GoodSleep
//
//  修复版本：
//  1. 用 AVPlayerLooper 替代 NotificationCenter 手动循环，消除循环引用
//  2. stopAll() 内前置 cancelFadeOut()，确保 Timer 被可靠 invalidate
//  3. 添加 @MainActor，消除数据竞争
//

import AVFoundation
import Foundation

@MainActor  // ✅ 修复3：添加 @MainActor，确保所有属性访问都在主线程，消除数据竞争
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
    private var players: [UUID: AVQueuePlayer] = [:]       // ✅ 修复1：改用 AVQueuePlayer 配合 AVPlayerLooper
    private var loopers: [UUID: AVPlayerLooper] = [:]      // ✅ 修复1：持有 looper，自动管理循环，无需 NotificationCenter
    private var baseVolumes: [UUID: Double] = [:]

    private var fadeTimer: Timer?
    private var fadeStartDate: Date?
    private var fadeEndDate: Date?

    // MARK: - Constants

    private enum Constants {
        static let fadeTickInterval: TimeInterval = 0.1
    }

    private init() {}

    deinit {
        fadeTimer?.invalidate()
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

    /// 停止所有播放
    func stopAll() {
        cancelFadeOut()  // ✅ 修复2：前置 cancelFadeOut()，确保 Timer 在清理 players 前被 invalidate

        for player in players.values {
            player.pause()
            player.removeAllItems()
        }

        // ✅ 修复1：释放所有 looper，自动停止循环，无需手动 removeObserver
        loopers.removeAll()
        players.removeAll()
        baseVolumes.removeAll()
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
            Task { @MainActor in
                self?.updateFadeProgress()
            }
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
        guard players[sound.id] == nil else { return }  // 防止重复创建

        configureAudioSessionIfNeeded()

        guard let url = validateAndGetURL(from: sound.url) else {
            print("[AudioPlayerManager] Invalid URL: \(sound.url)")
            return
        }

        // ✅ 修复1：用 AVPlayerLooper 实现循环播放
        // AVPlayerLooper 内部自动管理 AVPlayerItem 的复用与循环，
        // 不依赖 NotificationCenter，彻底消除 object 参数导致的循环引用
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        let looper = AVPlayerLooper(player: player, templateItem: item)

        player.volume = calculateVolume(baseVolume: sound.volume)
        player.play()

        players[sound.id] = player
        loopers[sound.id] = looper  // 必须持有 looper，否则 ARC 会立即释放导致循环停止
        baseVolumes[sound.id] = sound.volume
    }

    private func stopPlaying(_ sound: Sound) {
        guard let player = players[sound.id] else { return }

        player.pause()
        player.removeAllItems()

        // ✅ 修复1：移除 looper 即停止循环，无需手动操作 NotificationCenter
        loopers.removeValue(forKey: sound.id)
        players.removeValue(forKey: sound.id)
        baseVolumes.removeValue(forKey: sound.id)
    }

    /// 刷新所有播放器的音量（总音量或淡出变化时调用）
    private func refreshAllVolumes() {
        for (id, player) in players {
            let base = baseVolumes[id] ?? 1.0
            player.volume = calculateVolume(baseVolume: base)
        }
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

        if now >= end {
            applyFadeMultiplier(0.0)
            stopAll()
            return  // stopAll() 内已调用 cancelFadeOut()，无需重复调用
        }

        guard now > start else {
            applyFadeMultiplier(1.0)
            return
        }

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
