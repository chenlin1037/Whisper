//
//  SoundViewModel.swift
//  GoodSleep
//
//  Created by Cascade on 2026/1/23.
//  优化版本：线程安全 + 简化逻辑
//

import Foundation
import SwiftUI

@MainActor
final class SoundViewModel: ObservableObject {
    // MARK: - Properties

    private let soundManager = AllSoundManger.shared

    var sounds: [Sound] {
        soundManager.sounds
    }

    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - DTO

    private struct LocalSoundDTO: Decodable {
        let name: String
        let url: String
        let category: String?
        let icon: String?
    }

    // MARK: - Lifecycle

    init() {
        loadSounds()
    }

    // MARK: - Load Sounds

    func loadSounds() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let sounds = try await loadSoundsFromJSON()
                soundManager.sounds = sounds
                isLoading = false
            } catch {
                errorMessage = "加载声音失败: \(error.localizedDescription)"
                print("加载声音失败: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }

    private func loadSoundsFromJSON() async throws -> [Sound] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let fileURL = Bundle.main.url(forResource: "sound", withExtension: "json") else {
                    continuation.resume(throwing: NSError(
                        domain: "SoundViewModel",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "未找到 sound.json 文件"]
                    ))
                    return
                }

                do {
                    let data = try Data(contentsOf: fileURL)
                    let items = try JSONDecoder().decode([LocalSoundDTO].self, from: data)

                    let sounds = items.map { item -> Sound in
                        let iconName: String

                        if let icon = item.icon?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !icon.isEmpty
                        {
                            iconName = (icon as NSString).deletingPathExtension
                        } else {
                            iconName = "play"
                        }
                        let category: String
                        if let cat = item.category?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !cat.isEmpty
                        {
                            category = cat
                        } else {
                            category = "未分类"
                        }
                        return Sound(
                            name: item.name,
                            icon: iconName,
                            url: item.url,
                            volume: 0.5,
                            category: category
                        )
                    }

                    continuation.resume(returning: sounds)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - User Actions

    /// 切换单个声音的播放状态
    func toggle(sound: Sound) {
        objectWillChange.send()

        sound.isPlaying.toggle()
        AudioPlayerManager.shared.update(sound: sound)

        soundManager.syncPlayingSnapshot()
    }

    /// 播放全部（恢复上一次播放状态）
    func playAll() {
        soundManager.playAll()
    }

    /// 暂停全部（记录当前播放状态）
    func pauseAll() {
        soundManager.pauseAll()
    }

    /// 重置所有状态
    func reset() {
        soundManager.reset()
    }
}
