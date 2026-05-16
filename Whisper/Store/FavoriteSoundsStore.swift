//
//  FavoriteSoundsStore.swift
//  Whisper
//
//  收藏声音的本地存储
//

import Foundation

protocol FavoriteSoundsStore {
    func load() -> Set<String>
    func save(_ ids: Set<String>)
}

final class UserDefaultsFavoriteSoundsStore: FavoriteSoundsStore {
    private let key = "FavoriteSounds.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> Set<String> {
        guard let array = defaults.stringArray(forKey: key) else {
            return []
        }
        return Set(array)
    }

    func save(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}
