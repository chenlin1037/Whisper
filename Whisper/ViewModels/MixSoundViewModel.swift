import Foundation
import SwiftUI

@MainActor
final class MixSoundViewModel: ObservableObject {

    // MARK: - Published

    @Published private(set) var mixes: [MixSound] = []
    @Published var editingMix: MixSound?
    @Published var isCreating = false
    @Published var isEditing = false
    @Published var newMixName = ""
    @Published var selectedSoundStableIDs: Set<String> = []

    // MARK: - Dependencies

    private let soundManager = AllSoundManger.shared
    private let store: MixSoundStore

    // MARK: - Init

    init(store: MixSoundStore = UserDefaultsMixSoundStore()) {
        self.store = store
        self.mixes = store.load()
    }

    // MARK: - Computed

    var allSounds: [Sound] {
        soundManager.sounds
    }

    var selectedSounds: [Sound] {
        allSounds.filter { selectedSoundStableIDs.contains($0.stableID) }
    }

    // MARK: - Create From Current State

    func createMixFromCurrentState(name: String) {
        let playing = allSounds.filter { $0.isPlaying }
        guard !playing.isEmpty else { return }

        let items = playing.map {
            MixSoundItem(
                soundStableID: $0.stableID,
                volume: $0.volume
            )
        }

        let mix = MixSound(name: name, items: items)
        mixes.append(mix)
        persist()
    }

    // MARK: - Editing Flow

    func startCreating() {
        isCreating = true
        isEditing = false
        newMixName = ""
        selectedSoundStableIDs.removeAll()
        editingMix = nil
    }

    func startEditing(_ mix: MixSound) {
        editingMix = mix
        isEditing = true
        isCreating = false
        newMixName = mix.name
        selectedSoundStableIDs = Set(mix.items.map { $0.soundStableID })
    }

    func cancelEditing() {
        isCreating = false
        isEditing = false
        newMixName = ""
        selectedSoundStableIDs.removeAll()
        editingMix = nil
    }

    // MARK: - Save

    func saveMix() {
        let name = newMixName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !selectedSoundStableIDs.isEmpty else { return }

        let items = selectedSoundStableIDs.map { stableID in
            let sound = allSounds.first { $0.stableID == stableID }
            return MixSoundItem(
                soundStableID: stableID,
                volume: sound?.volume ?? 0.5
            )
        }

        if isEditing, var mix = editingMix,
           let index = mixes.firstIndex(where: { $0.id == mix.id }) {

            mix.name = name
            mix.items = items
            mix.touch()
            mixes[index] = mix

        } else {
            let mix = MixSound(name: name, items: items)
            mixes.append(mix)
        }

        persist()
        cancelEditing()
    }

    // MARK: - Delete

    func delete(_ mix: MixSound) {
        mixes.removeAll { $0.id == mix.id }
        persist()
    }

    // MARK: - Play

    func play(_ mix: MixSound) {
        soundManager.pauseAll()

        for item in mix.items {
            guard let sound = allSounds.first(where: {
                $0.stableID == item.soundStableID
            }) else { continue }

            sound.isPlaying = true
            sound.volume = item.volume
            AudioPlayerManager.shared.update(sound: sound)
        }

        soundManager.syncPlayingSnapshot()
    }
    
    // MARK: - Mix Detail Methods (添加到 ViewModel 中)

    func soundsForMix(_ mix: MixSound) -> [(Sound, Double)] {
        mix.items.compactMap { item in
            guard let sound = allSounds.first(where: { $0.stableID == item.soundStableID }) else {
                return nil
            }
            return (sound, item.volume)
        }
    }

    func updateMixSoundVolume(mix: MixSound, stableID: String, volume: Double) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }
        var updatedMix = mixes[index]
        
        if let itemIndex = updatedMix.items.firstIndex(where: { $0.soundStableID == stableID }) {
            updatedMix.items[itemIndex].volume = volume
            updatedMix.touch()
            mixes[index] = updatedMix
            persist()
        }
    }

    func toggleMixSoundPlaying(mix: MixSound, stableID: String) {
        guard let sound = allSounds.first(where: { $0.stableID == stableID }) else { return }
        
        sound.isPlaying.toggle()
        
        if sound.isPlaying {
            // 从 mix 中获取保存的音量
            if let item = mix.items.first(where: { $0.soundStableID == stableID }) {
                sound.volume = item.volume
            }
        }
        
        AudioPlayerManager.shared.update(sound: sound)
        soundManager.syncPlayingSnapshot()
    }

    func removeSoundFromMix(mix: MixSound, stableID: String) {
        guard let index = mixes.firstIndex(where: { $0.id == mix.id }) else { return }
        var updatedMix = mixes[index]
        
        updatedMix.items.removeAll { $0.soundStableID == stableID }
        updatedMix.touch()
        
        if updatedMix.items.isEmpty {
            // 如果没有声音了，删除整个 mix
            mixes.remove(at: index)
        } else {
            mixes[index] = updatedMix
        }
        
        persist()
        
        // 停止播放该声音
        if let sound = allSounds.first(where: { $0.stableID == stableID }) {
            sound.isPlaying = false
            AudioPlayerManager.shared.update(sound: sound)
        }
    }

    // MARK: - Helpers

    func isSelected(_ sound: Sound) -> Bool {
        selectedSoundStableIDs.contains(sound.stableID)
    }

    func toggleSelection(_ sound: Sound) {
        if isSelected(sound) {
            selectedSoundStableIDs.remove(sound.stableID)
        } else {
            selectedSoundStableIDs.insert(sound.stableID)
        }
    }

    private func persist() {
        mixes.sort { $0.updatedAt > $1.updatedAt }
        store.save(mixes)
    }
}
