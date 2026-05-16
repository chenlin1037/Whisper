//
//  SleepTimerView.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//

import SwiftUI

struct SleepTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = SleepTimerViewModel.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 顶部状态显示
                if viewModel.isTimerActive {
                    timerActiveView
                } else {
                    timerSetupView
                }

                Spacer()

                // 主操作按钮
                actionButtons
            }
            .padding()
            .navigationTitle("睡眠定时")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isTimerActive {
                        Button("停止", role: .destructive) {
                            viewModel.cancelTimer()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timer Active View

    private var timerActiveView: some View {
        VStack(spacing: 16) {
            Text(viewModel.formattedRemainingTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)

            // 使用 Gauge 替代 ProgressView
            Gauge(
                value: Double(viewModel.remainingSeconds),
                in: 0 ... Double(viewModel.totalTimeInSeconds)
            ) {
                // 可选：自定义标签（这里留空）
            }
            .gaugeStyle(.accessoryCircular) // 环形样式
            .tint(Color.appTheme)
            .scaleEffect(2.2) // 👈 放大环形
            .frame(width: 200, height: 200)
        }
        .padding()
    }

    // MARK: - Timer Setup View

    private var timerSetupView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Picker("Hours", selection: $viewModel.hours) {
                    ForEach(0 ... 23, id: \.self) { hour in
                        Text("\(hour) hours").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()

                Picker("Minutes", selection: $viewModel.minutes) {
                    ForEach(0 ... 59, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Quick Set Buttons

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if viewModel.isTimerActive {
                Button(action: { viewModel.cancelTimer() }) {
                    Label("取消定时", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: { viewModel.startTimer() }) {
                    Label("开始", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isValidTime ? Color.appTheme : Color(.systemGray3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.isValidTime)
                .buttonStyle(.plain)

                if viewModel.hours > 0 || viewModel.minutes > 0 {
                    Button("重置", action: { viewModel.reset() })
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    SleepTimerView()
}
