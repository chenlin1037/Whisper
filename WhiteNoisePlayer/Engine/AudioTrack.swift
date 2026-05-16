//
//  AudioTrack.swift
//  WhiteNoisePlayer
//

import AVFoundation

final class AudioTrack: Identifiable, ObservableObject {
    let id: String
    let displayName: String
    let artworkName: String?
    let player: AVAudioPlayerNode

    // 只在 MainActor 读写，驱动 SwiftUI
    @MainActor @Published private(set) var volume: Float

    init(id: String, player: AVAudioPlayerNode, volume: Float = 1.0, displayName: String? = nil, artworkName: String? = nil) {
        self.id = id
        self.displayName = displayName ?? id
        self.artworkName = artworkName
        self.player = player
        self._volume = Published(initialValue: volume)  // 直接初始化 @Published 的底层存储
        player.volume = volume
    }

    /// 由 WhiteNoiseEngine.runFade 在主线程调用，更新 UI 显示的音量值
    @MainActor
    func applyUIVolume(_ value: Float) {
        volume = value
    }
}
