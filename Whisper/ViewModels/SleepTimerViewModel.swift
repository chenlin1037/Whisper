//
//  SleepTimerViewModel.swift
//  Whisper
//
//  仅负责 UI 输入（hours/minutes）与时间展示，业务逻辑下沉至 SleepTimerService
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class SleepTimerViewModel: ObservableObject {
    static let shared = SleepTimerViewModel()

    // MARK: - UI 输入

    @Published var hours: Int = 0
    @Published var minutes: Int = 0

    // MARK: - Service（业务状态）

    private let timerService: SleepTimerService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - 暴露给 UI

    var isTimerActive: Bool {
        timerService.isTimerActive
    }

    var remainingSeconds: Int {
        timerService.remainingSeconds
    }

    var totalTimeInSeconds: Int {
        timerService.totalTimeInSeconds
    }

    var isValidTime: Bool {
        (hours * 3600 + minutes * 60) > 0
    }

    var formattedRemainingTime: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    var shortRemainingTime: String {
        guard remainingSeconds > 0 else { return "" }
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d", h, m)
        } else if m > 0 {
            return String(format: "%dm", m)
        } else {
            return String(format: "%ds", s)
        }
    }

    // MARK: - Init

    /// 通过可选注入避免在默认参数中直接调用 MainActor 隔离的初始化器
    private init(timerService: SleepTimerService? = nil) {
        let service = timerService ?? SleepTimerService()
        self.timerService = service
        service.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - 业务委托

    func startTimer() {
        let totalSeconds = hours * 3600 + minutes * 60
        timerService.startTimer(totalSeconds: totalSeconds)
        objectWillChange.send()
    }

    func cancelTimer() {
        timerService.cancelTimer()
        objectWillChange.send()
    }

    func reset() {
        timerService.cancelTimer()
        hours = 0
        minutes = 0
    }
}
