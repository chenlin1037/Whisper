//
//  MixSoundViewModel.swift
//  Whisper
//
//  仅负责编辑流 UI 状态与数据组织，业务逻辑下沉至 MixSoundService
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
    private let soundManager = AllSoundManger.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 暴露给 UI 的数据（来自 Service）

    var mixes: [MixSound] {
        mixService.mixes
    }

    var allSounds: [Sound] {
        soundManager.sounds
    }

    var selectedSounds: [Sound] {
        allSounds.filter { selectedSoundStableIDs.contains($0.stableID) }
    }

    // MARK: - Init

    /// 通过可选依赖注入，避免在默认参数中直接调用 MainActor 隔离的初始化器
    init(mixService: MixSoundService? = nil) {
        let service = mixService ?? MixSoundService()
        self.mixService = service
        service.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - 编辑流（UI 状态）

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
        objectWillChange.send()
    }

    func delete(_ mix: MixSound) {
        mixService.deleteMix(mix)
        objectWillChange.send()
    }

    func togglePin(_ mix: MixSound) {
        mixService.togglePin(mix)
        objectWillChange.send()
    }

    func play(_ mix: MixSound) {
        mixService.playMix(mix)
    }

    func soundsForMix(_ mix: MixSound) -> [(Sound, Double)] {
        mixService.soundsForMix(mix)
    }

    func updateMixSoundVolume(mix: MixSound, stableID: String, volume: Double) {
        mixService.updateMixVolume(mix: mix, stableID: stableID, volume: volume)
        objectWillChange.send()
    }

    func toggleMixSoundPlaying(mix: MixSound, stableID: String) {
        mixService.toggleSoundInMix(mix: mix, stableID: stableID)
        objectWillChange.send()
    }

    func removeSoundFromMix(mix: MixSound, stableID: String) {
        mixService.removeSoundFromMix(mix: mix, stableID: stableID)
        objectWillChange.send()
    }

    // MARK: - 选择状态（纯 UI）

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
