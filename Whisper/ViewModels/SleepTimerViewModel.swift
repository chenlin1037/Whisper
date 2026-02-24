//
//  SleepTimerViewModel.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//

import Foundation
import SwiftUI

@MainActor
final class SleepTimerViewModel: ObservableObject {
    // MARK: - Singleton

    static let shared = SleepTimerViewModel()

    // MARK: - Published Properties

    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published private(set) var isTimerActive: Bool = false // 是否激活
    @Published private(set) var remainingSeconds: Int = 0 // 剩余时间
    @Published private(set) var totalTimeInSeconds: Int = 0 // 总时间

    // MARK: - Private Properties

    private var timerTask: Task<Void, Never>?
    private var endTime: Date? // 结束时间

    // UserDefaults keys
    private let endTimeKey = "SleepTimerEndTime" // 结束时间 key
    private let isActiveKey = "SleepTimerIsActive" // 是否激活 key
    private let totalTimeKey = "SleepTimerTotalTime" // 总时间 key

    // MARK: - Computed Properties

    var isValidTime: Bool {
        (hours * 3600 + minutes * 60) > 0
    }

    var formattedRemainingTime: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// 简短的剩余时间显示（用于 PlayingBarView）
    var shortRemainingTime: String {
        guard remainingSeconds > 0 else { return "" }

        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    // MARK: - Lifecycle

    private init() {
        // 应用重启时不恢复定时器状态，允许用户重新设置
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Private Methods

    /// 启动定时器任务
    private func startTimerTask() {
        timerTask?.cancel()

        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                guard let endTime = self.endTime else { break }

                let remaining = Int(endTime.timeIntervalSinceNow)
                let newRemainingSeconds = max(0, remaining)

                // 更新剩余时间（这会触发 UI 更新）
                self.remainingSeconds = newRemainingSeconds

                // 更新持久化状态
                self.persistTimerState()

                // 时间到了
                if remaining <= 0 {
                    AllSoundManger.shared.pauseAll() // 暂停所有声音
                    self.isTimerActive = false
                    self.remainingSeconds = 0
                    self.clearPersistedState() // 清除持久化状态
                    break
                }

                // 等待 1 秒后继续
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    /// 持久化定时器状态
    private func persistTimerState() {
        if let endTime = endTime {
            UserDefaults.standard.set(endTime, forKey: endTimeKey)
            UserDefaults.standard.set(isTimerActive, forKey: isActiveKey)
            UserDefaults.standard.set(totalTimeInSeconds, forKey: totalTimeKey)
        }
    }

    /// 清除持久化状态
    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: endTimeKey)
        UserDefaults.standard.removeObject(forKey: isActiveKey)
        UserDefaults.standard.removeObject(forKey: totalTimeKey)
    }

    // MARK: - Public Methods

    /// 开始定时器
    func startTimer() {
        // 如果定时器已经在运行，不允许启动新定时器
        guard !isTimerActive else { return }
        guard isValidTime else { return }

        let totalSeconds = hours * 3600 + minutes * 60
        cancelTimer()

        isTimerActive = true
        remainingSeconds = totalSeconds
        totalTimeInSeconds = totalSeconds
        endTime = Date().addingTimeInterval(TimeInterval(totalSeconds))

        // 持久化状态
        persistTimerState()

        // 启动定时器任务
        startTimerTask()
    }

    /// 取消定时器
    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil

        isTimerActive = false
        remainingSeconds = 0
        totalTimeInSeconds = 0
        endTime = nil

        // 清除持久化状态
        clearPersistedState()
    }

    /// 重置时间设置
    func reset() {
        cancelTimer()
        hours = 0
        minutes = 0
    }
}
