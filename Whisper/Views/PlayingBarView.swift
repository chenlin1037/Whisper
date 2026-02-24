//
//  PlayingBarView.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//  Simplified & Explicit Version
//

import SwiftUI
import UIKit

struct PlayingBarView: View {
    // MARK: - State

    @ObservedObject var viewModel: PlayingBarViewModel
    @ObservedObject private var sleepTimerViewModel = SleepTimerViewModel.shared

    @State private var showSleepTimer = false
    @State private var showSoundSettings = false

    /// 行为由外部注入（不使用事件 / 订阅）
    let onTogglePlayPause: (Bool) -> Void
    let onShowSleepTimer: () -> Void
    let onShowSoundSettings: (Sound?) -> Void

    // MARK: - Constants

    private enum Layout {
        static let height: CGFloat = 68
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 36
        static let borderWidth: CGFloat = 0.5
    }

    var body: some View {
        NavigationStack {
            barContent
        }
        .sheet(isPresented: $showSleepTimer) {
            SleepTimerView()
        }
        .sheet(isPresented: $showSoundSettings) {
            SoundSettingsView()
        }
    }

    // MARK: - Main Content

    private var barContent: some View {
        HStack {
            controlSection
        }
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.padding)
        .frame(height: Layout.height)
        .background(barBackground)
    }

    // MARK: - Control Section

    private var controlSection: some View {
        HStack(spacing: Layout.spacing) {
            BarButton(
                icon: playPauseIcon,
                action: {
                    viewModel.togglePlayPause { shouldPlay in
                        onTogglePlayPause(shouldPlay)
                    }
                },
                hapticStyle: .medium,
                scale: 0.88,
                iconOffset: viewModel.isAllPaused ? 1 : 0,
                useSymbolTransition: true
            )

            // TimerButton(
            //     isActive: sleepTimerViewModel.isTimerActive,
            //     remainingTime: sleepTimerViewModel.shortRemainingTime,
            //     action: {
            //         showSleepTimer = true
            //     }
            // )

            BarButton(
                icon: "timer",
                action: {
                    // viewModel.showSoundSettings { sound in
                    //     onShowSoundSettings(sound)
                    // }
                    showSleepTimer = true
                },
                hapticStyle: .light,
                scale: 0.92
            )

            BarButton(
                icon: "slider.horizontal.3",
                action: {
                    // viewModel.showSoundSettings { sound in
                    //     onShowSoundSettings(sound)
                    // }
                    showSoundSettings = true
                },
                hapticStyle: .light,
                scale: 0.92
            )
        }
    }

    // MARK: - Background（简洁：系统材质 + 主题色描边）

    private var barBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(Color.appTheme.opacity(0.25), lineWidth: Layout.borderWidth)
            )
    }

    // MARK: - Computed Properties

    private var playPauseIcon: String {
        viewModel.isAllPaused ? "play.fill" : "pause.fill"
    }
}

// MARK: - Timer Button Component

struct TimerButton: View {
    let isActive: Bool
    let remainingTime: String
    let action: () -> Void

    private enum Layout {
        static let buttonSize: CGFloat = 44
        static let iconSize: CGFloat = 18
        static let timeFontSize: CGFloat = 10
        static let spacing: CGFloat = 4
    }

    var body: some View {
        Button {
            HapticFeedback.impact(style: .light)
            action()
        } label: {
            VStack(spacing: Layout.spacing) {
                ZStack {
                    Circle()
                        .fill(Color.appTheme)
                        .frame(width: Layout.buttonSize, height: Layout.buttonSize)

                    Image(systemName: "timer")
                        .font(.system(size: Layout.iconSize, weight: .semibold))
                        .foregroundStyle(.white)
                }

                if isActive {
                    Text(remainingTime)
                        .font(.system(size: Layout.timeFontSize, weight: .medium))
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                }
            }
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.92))
    }
}

// MARK: - Bar Button Component

struct BarButton: View {
    let icon: String
    let action: () -> Void
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    var scale: CGFloat = 0.92
    var iconOffset: CGFloat = 0
    var useSymbolTransition: Bool = false

    private enum Layout {
        static let buttonSize: CGFloat = 44
        static let iconSize: CGFloat = 18
    }

    var body: some View {
        Button {
            HapticFeedback.impact(style: hapticStyle)
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.appTheme)
                    .frame(width: Layout.buttonSize, height: Layout.buttonSize)

                if useSymbolTransition {
                    Image(systemName: icon)
                        .font(.system(size: Layout.iconSize, weight: .semibold))
                        .foregroundStyle(.white)
                        .offset(x: iconOffset)
                        .contentTransition(.symbolEffect(.replace))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: Layout.iconSize, weight: .semibold))
                        .foregroundStyle(.white)
                        .offset(x: iconOffset)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle(scale: scale))
    }
}

// MARK: - Haptic Feedback Helper

enum HapticFeedback {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Custom Button Style

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.9

    private enum Animation {
        static let springResponse: Double = 0.3
        static let springDamping: Double = 0.65
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(
                .spring(response: Animation.springResponse, dampingFraction: Animation.springDamping),
                value: configuration.isPressed
            )
    }
}

// MARK: - Custom Shape

struct TopRoundedRectangleShape: Shape {
    var cornerRadius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
