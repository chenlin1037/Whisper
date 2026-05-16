//
//  MixSoundViewModel.swift
//  Whisper
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class MixSoundViewModel: ObservableObject {

    // MARK: - Published (UI 状态)

    @Published var editingMix: MixSound?
    @Published var isCreating = false
    @Published var isEditing = false
    @Published var newMixName = ""
    @Published var selectedSoundStableIDs: Set<String> = []

    // MARK: - Dependencies

    private let mixService: MixSoundService
    private let soundManager: AllSoundManger
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 暴露给 UI 的数据

    var mixes: [MixSound] {
        mixService.mixes
    }

    var allSounds: [Sound] {
        soundManager.sounds
    }

    var selectedSounds: [Sound] {
        allSounds.filter { selectedSoundStableIDs.contains($0.stableID) }
    }

    // MARK: - Init（✅彻底解决 Swift 6 问题）

    init(
        mixService: MixSoundService,
        soundManager: AllSoundManger
    ) {
        self.mixService = mixService
        self.soundManager = soundManager

        mixService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - 编辑流

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
        selectedSoundStableIDs = Set(mix.items.map(\.soundStableID))
    }

    func cancelEditing() {
        isCreating = false
        isEditing = false
        newMixName = ""
        selectedSoundStableIDs.removeAll()
        editingMix = nil
    }

    // MARK: - 业务委托

    func createMixFromCurrentState(name: String) {
        mixService.createMixFromCurrentState(name: name)
    }

    func saveMix() {
        mixService.saveMix(
            name: newMixName,
            selectedSoundStableIDs: selectedSoundStableIDs,
            editingMix: isEditing ? editingMix : nil
        )
        cancelEditing()
    }

    func delete(_ mix: MixSound) {
        mixService.deleteMix(mix)
    }

    func togglePin(_ mix: MixSound) {
        mixService.togglePin(mix)
    }

    func play(_ mix: MixSound) {
        mixService.playMix(mix)
    }

    func soundsForMix(_ mix: MixSound) -> [(Sound, Double)] {
        mixService.soundsForMix(mix)
    }

    func updateMixSoundVolume(mix: MixSound, stableID: String, volume: Double) {
        mixService.updateMixVolume(mix: mix, stableID: stableID, volume: volume)
    }

    func toggleMixSoundPlaying(mix: MixSound, stableID: String) {
        mixService.toggleSoundInMix(mix: mix, stableID: stableID)
    }

    func removeSoundFromMix(mix: MixSound, stableID: String) {
        mixService.removeSoundFromMix(mix: mix, stableID: stableID)
    }

    // MARK: - 选择状态

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
}
