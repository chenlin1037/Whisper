//
//  AllSoundManager.swift
//  GoodSleep
//
//  优化版本：线程安全 + 内存管理
//

import AVFoundation
import Foundation

@MainActor
final class AllSoundManger: ObservableObject {
    static let shared = AllSoundManger()

    @Published var sounds: [Sound] = []

    private var lastPlayingSoundIDs = Set<UUID>()

    private init() {}

    // MARK: - Public Methods

    /// 切换单个声音的播放状态
    func toggleSound(_ sound: Sound) {
        objectWillChange.send()
        sound.isPlaying.toggle()
        AudioPlayerManager.shared.update(sound: sound)
        syncPlayingSnapshot()
    }

    /// 播放全部（恢复上一次播放状态）
    func playAll() {
        objectWillChange.send()

        // 如果没有历史记录，则不执行任何播放操作
        guard !lastPlayingSoundIDs.isEmpty else {
            return
        }

        // 恢复上次播放状态
        for sound in sounds {
            let shouldPlay = lastPlayingSoundIDs.contains(sound.id)
            sound.isPlaying = shouldPlay
            AudioPlayerManager.shared.update(sound: sound)
        }
    }

    /// 暂停全部（记录当前播放状态）
    func pauseAll() {
        objectWillChange.send()

        // 保存当前播放状态
        syncPlayingSnapshot()

        let currentlyPlaying = sounds.filter { $0.isPlaying }

        for sound in currentlyPlaying {
            sound.isPlaying = false
            AudioPlayerManager.shared.update(sound: sound)
        }
    }

    /// 同步当前播放快照
    func syncPlayingSnapshot() {
        objectWillChange.send()
        let currentlyPlaying = sounds.filter { $0.isPlaying }
        lastPlayingSoundIDs = Set(currentlyPlaying.map(\.id))
    }

    /// 重置所有状态
    func reset() {
        pauseAll()
        lastPlayingSoundIDs.removeAll()
    }
}
