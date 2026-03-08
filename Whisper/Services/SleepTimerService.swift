//
//  SleepTimerService.swift
//  Whisper
//
//  睡眠定时业务逻辑：计时、持久化、结束时暂停播放
//

import Foundation
import SwiftUI

@MainActor
final class SleepTimerService: ObservableObject {
    @Published private(set) var isTimerActive: Bool = false
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var totalTimeInSeconds: Int = 0

    private var timerTask: Task<Void, Never>?
    private var endTime: Date?

    private let endTimeKey = "SleepTimerEndTime"
    private let isActiveKey = "SleepTimerIsActive"
    private let totalTimeKey = "SleepTimerTotalTime"

    private let soundManager: AllSoundManger

    init(soundManager: AllSoundManger = .shared) {
        self.soundManager = soundManager
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Public

    func startTimer(totalSeconds: Int) {
        guard !isTimerActive else { return }
        guard totalSeconds > 0 else { return }

        cancelTimer()

        isTimerActive = true
        remainingSeconds = totalSeconds
        totalTimeInSeconds = totalSeconds
        endTime = Date().addingTimeInterval(TimeInterval(totalSeconds))

        persistTimerState()
        startTimerTask()
    }

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil

        isTimerActive = false
        remainingSeconds = 0
        totalTimeInSeconds = 0
        endTime = nil

        clearPersistedState()
    }

    // MARK: - Private

    private func startTimerTask() {
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                guard let endTime = self.endTime else { break }

                let remaining = Int(endTime.timeIntervalSinceNow)
                self.remainingSeconds = max(0, remaining)

                persistTimerState()

                if remaining <= 0 {
                    soundManager.pauseAll()
                    self.isTimerActive = false
                    self.remainingSeconds = 0
                    clearPersistedState()
                    break
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private func persistTimerState() {
        if let endTime = endTime {
            UserDefaults.standard.set(endTime, forKey: endTimeKey)
            UserDefaults.standard.set(isTimerActive, forKey: isActiveKey)
            UserDefaults.standard.set(totalTimeInSeconds, forKey: totalTimeKey)
        }
    }

    private func clearPersistedState() {
        UserDefaults.standard.removeObject(forKey: endTimeKey)
        UserDefaults.standard.removeObject(forKey: isActiveKey)
        UserDefaults.standard.removeObject(forKey: totalTimeKey)
    }
}
