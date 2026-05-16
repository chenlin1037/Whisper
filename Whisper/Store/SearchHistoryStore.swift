// SearchHistoryStore.swift

import Foundation

protocol SearchHistoryStore {
    func load() -> [String]
    func save(_ history: [String])
    func clear()
}

final class UserDefaultsSearchHistoryStore: SearchHistoryStore {
    private let key = "SearchHistory.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [String] {
        return defaults.stringArray(forKey: key) ?? []
    }

    func save(_ history: [String]) {
        defaults.set(history, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}