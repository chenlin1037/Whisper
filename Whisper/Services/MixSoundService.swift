//
//  MixSoundService.swift
//  Whisper
//
//  混合声音业务逻辑：CRUD、播放策略、持久化
//

import Foundation
import SwiftUI

@MainActor
final class MixSoundService: ObservableObject {
    @Published private(set) var mixes: [MixSound] = []

    private let store: MixSoundStore
    private let soundManager: AllSoundManger

    // ✅ Swift 6 安全写法：移除 .shared 默认参数
    init(
        store: MixSoundStore = UserDefaultsMixSoundStore(),
        soundManager: AllSoundManger
    ) {
        self.store = store
        self.soundManager = soundManager
        self.mixes = store.load()
        sortMixes()
    }

    // MARK: - CRUD

    func saveMix(name: String, selectedSoundStableIDs: Set<String>, editingMix: MixSound?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !selectedSoundStableIDs.isEmpty else { return }

        let allSounds = soundManager.sounds

        let items = selectedSoundStableIDs.map { stableID in
            let sound = allSounds.first { $0.stableID == stableID }
            return MixSoundItem(
                soundStableID: stableID,
                volume: sound?.volume ?? 0.5
            )
        }

        if let mix = editingMix,
           let index = mixes.firstIndex(where: { $0.id == mix.id }) {

            var updated = mixes[index]
            updated.name = trimmedName
            updated.items = items
            updated.touch()
            mixes[index] = updated

        } else {
            mixes.append(MixSound(name: trimmedName, items: items))
        }

        sortMixes()
        persist()
    }

    func deleteMix(_ mix: MixSound) {
        mixes.removeAll { $0.id == mix.id }
        persist()
    }

    func togglePin(_ mix: MixSound) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }
        mixes[index].isPinned.toggle()
        sortMixes()
        persist()
    }

    // MARK: - Create From Current State

    func createMixFromCurrentState(name: String) {
        let playing = soundManager.sounds.filter { $0.isPlaying }
        guard !playing.isEmpty else { return }

        let items = playing.map {
            MixSoundItem(soundStableID: $0.stableID, volume: $0.volume)
        }

        mixes.append(MixSound(name: name, items: items))
        sortMixes()
        persist()
    }

    // MARK: - Play

    func playMix(_ mix: MixSound) {
        soundManager.pauseAll()

        // ✅ 修复 allSounds 未定义
        let allSounds = soundManager.sounds

        for item in mix.items {
            guard let sound = allSounds.first(where: {
                $0.stableID == item.soundStableID
            }) else { continue }

            sound.volume = item.volume
            sound.isPlaying = true
            soundManager.toggleSound(sound)
        }
    }

    // MARK: - Mix Detail

    func soundsForMix(_ mix: MixSound) -> [(Sound, Double)] {
        let allSounds = soundManager.sounds

        return mix.items.compactMap { item in
            guard let sound = allSounds.first(where: {
                $0.stableID == item.soundStableID
            }) else {
                return nil
            }
            return (sound, item.volume)
        }
    }

    func updateMixVolume(mix: MixSound, stableID: String, volume: Double) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }
        guard let itemIndex = mixes[index].items.firstIndex(where: {
            $0.soundStableID == stableID
        }) else { return }

        mixes[index].items[itemIndex].volume = volume
        mixes[index].touch()
        persist()
    }

    func toggleSoundInMix(mix: MixSound, stableID: String) {
        guard let sound = soundManager.sounds.first(where: {
            $0.stableID == stableID
        }) else { return }

        sound.isPlaying.toggle()

        if sound.isPlaying,
           let item = mix.items.first(where: {
               $0.soundStableID == stableID
           }) {
            sound.volume = item.volume
        }

        // ⚠️ 假设 AudioPlayerManager 也是 @MainActor（推荐）
        AudioPlayerManager.shared.update(sound: sound)
        soundManager.syncPlayingSnapshot()
    }

    func removeSoundFromMix(mix: MixSound, stableID: String) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }

        // 先停止声音
        if let sound = soundManager.sounds.first(where: {
            $0.stableID == stableID
        }) {
            sound.isPlaying = false
            AudioPlayerManager.shared.update(sound: sound)
        }

        mixes[index].items.removeAll { $0.soundStableID == stableID }
        mixes[index].touch()

        if mixes[index].items.isEmpty {
            mixes.remove(at: index)
        }

        persist()
    }

    // MARK: - Persist

    private func persist() {
        store.save(mixes)
    }

    private func sortMixes() {
        mixes.sort { a, b in
            if a.isPinned != b.isPinned {
                return a.isPinned
            }
            return a.updatedAt > b.updatedAt
        }
    }
}
