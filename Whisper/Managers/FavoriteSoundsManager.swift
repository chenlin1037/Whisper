//
//  FavoriteSoundsManager.swift
//  Whisper
//
//  收藏声音业务逻辑：委托 Store 持久化
//

import Foundation
import SwiftUI

@MainActor
final class FavoriteSoundsManager: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []

    private let store: FavoriteSoundsStore

    init(store: FavoriteSoundsStore = UserDefaultsFavoriteSoundsStore()) {
        self.store = store
        self.favoriteIDs = store.load()
    }

    func isFavorite(_ sound: Sound) -> Bool {
        favoriteIDs.contains(sound.stableID)
    }

    func toggleFavorite(_ sound: Sound) {
        if favoriteIDs.contains(sound.stableID) {
            favoriteIDs.remove(sound.stableID)
        } else {
            favoriteIDs.insert(sound.stableID)
        }
        store.save(favoriteIDs)
    }
}
