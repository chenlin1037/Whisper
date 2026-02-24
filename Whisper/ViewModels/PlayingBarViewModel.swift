//
//  PlayingBarViewModel.swift
//  GoodSleep
//
//  优化版本：自动监听 AllSoundManger 状态变化
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PlayingBarViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 正在播放的声音
    @Published private(set) var playingSounds: [Sound] = []

    // MARK: - Private Properties

    private let soundManager = AllSoundManger.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// 是否全部暂停
    var isAllPaused: Bool {
        playingSounds.isEmpty
    }

    /// 当前显示的声音（UI 只展示第一个）
    var displaySound: Sound? {
        playingSounds.first
    }

    // MARK: - Lifecycle

    init() {
        setupObservers()
        // 初始化时同步一次状态
        syncPlayingSounds()
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - Setup Observers

    private func setupObservers() {
        // 合并两路更新并防抖，减少瞬态分配与重复 sync（缓解 6 分钟后总内存/瞬态数量攀升）
        let soundsChanged = soundManager.$sounds
            .map { _ in () }
        let stateChanged = soundManager.objectWillChange
            .map { _ in () }
        Publishers.Merge(soundsChanged, stateChanged)
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(80), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.syncPlayingSounds()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    /// 同步正在播放的声音
    private func syncPlayingSounds() {
        let newPlayingSounds = soundManager.sounds.filter { $0.isPlaying }

        // 只在有变化时更新，避免不必要的 UI 刷新
        if newPlayingSounds.map(\.id) != playingSounds.map(\.id) {
            playingSounds = newPlayingSounds
        }
    }

    // MARK: - Public Methods

    /// 外部传入所有声音状态（向后兼容，但已不再必需）
    @available(*, deprecated, message: "不再需要手动调用，会自动同步")
    func updateSounds(_ sounds: [Sound]) {
        playingSounds = sounds.filter { $0.isPlaying }
    }

    /// 点击播放 / 暂停按钮
    func togglePlayPause(onToggle: (Bool) -> Void) {
        // true = 播放，false = 暂停
        onToggle(isAllPaused)
    }

    /// 点击展开播放列表
    func expandPlayingList(onShow: ([Sound]) -> Void) {
        onShow(playingSounds)
    }

    /// 点击音效设置
    func showSoundSettings(onShow: (Sound?) -> Void) {
        onShow(displaySound)
    }

    /// 手动刷新（通常不需要调用）
    func refresh() {
        syncPlayingSounds()
    }
}
