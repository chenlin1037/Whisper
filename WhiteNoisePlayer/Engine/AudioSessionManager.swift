//
//  AudioSessionManager.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

import AVFoundation

final class AudioSessionManager {

    func configure() {
        do {
            try activateForPlayback()
        } catch {
            // 配置失败时记录日志，避免用 try? 静默吞掉错误
            print("[AudioSessionManager] 配置失败: \(error)")
        }
    }

    func activateForPlayback() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [])
        try session.setActive(true)
    }
}
