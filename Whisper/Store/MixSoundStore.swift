//
//  MixSoundStore.swift
//  Whisper
//
//  Created by luckly on 2026/2/10.
//


import Foundation

protocol MixSoundStore {
    func load() -> [MixSound]
    func save(_ mixes: [MixSound])
    func clear()
}

// MARK: - UserDefaults 实现

final class UserDefaultsMixSoundStore: MixSoundStore {

    private let key = "MixSounds.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [MixSound] {
        guard
            let data = defaults.data(forKey: key),
            let mixes = try? JSONDecoder().decode([MixSound].self, from: data)
        else {
            return []
        }
        return mixes.sorted { $0.updatedAt > $1.updatedAt }
    }

    func save(_ mixes: [MixSound]) {
        guard let data = try? JSONEncoder().encode(mixes) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
