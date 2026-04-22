//
//  SoundViewModel.swift
//  Whisper
//
//  仅负责数据组织与 UI 状态，业务逻辑下沉至 Manager / Service
//

import Foundation
import SwiftUI

@MainActor
final class SoundViewModel: ObservableObject {
    private let soundManager = AllSoundManger.shared
    private let favoriteManager: FavoriteSoundsManager

    var sounds: [Sound] {
        soundManager.sounds
    }

    var favoriteIDs: Set<String> {
        favoriteManager.favoriteIDs
    }

    var favoriteSounds: [Sound] {
        sounds.filter { favoriteManager.favoriteIDs.contains($0.stableID) }
    }

    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    init(favoriteManager: FavoriteSoundsManager? = nil) {
        self.favoriteManager = favoriteManager ?? FavoriteSoundsManager()
        loadSounds()
    }

    // MARK: - Load (委托 SoundLoader)

    func loadSounds() {
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let sounds = try await SoundLoader.loadFromBundle()
                self.soundManager.sounds = sounds
                self.isLoading = false
            } catch {
                self.errorMessage = "加载声音失败: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // MARK: - Favorites (委托 FavoriteSoundsManager)

    func isFavorite(_ sound: Sound) -> Bool {
        favoriteManager.isFavorite(sound)
    }

    func toggleFavorite(_ sound: Sound) {
        favoriteManager.toggleFavorite(sound)
    }

    // MARK: - Play (委托 AllSoundManager)

    func toggle(sound: Sound) {
        soundManager.toggleSound(sound)
    }

    func playAll() {
        soundManager.playAll()
    }

    func pauseAll() {
        soundManager.pauseAll()
    }

    func reset() {
        soundManager.reset()
    }
}
