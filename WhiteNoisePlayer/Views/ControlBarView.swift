//
//  ControlBarView.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

// MARK: - File: ControlBarView.swift

// 底部控制栏：播放/暂停、停止、睡眠定时器

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var vm: PlayerViewModel
    @State private var showSleepPicker = false
    @State private var showSoundSettingsPicker = false
    @State private var showMixLibrary = false

    var body: some View {
        VStack(spacing: 8) {
            // if vm.anyActive {
            //     HStack {
            //         Text(
            //             vm.isPlaying
            //                 ? "Playing \(vm.activeTracks.count) Sounds"
            //                 : "\(vm.activeTracks.count) Sounds Selected"
            //         )
            //         .font(.system(size: 13, weight: .semibold, design: .rounded))
            //         .foregroundStyle(Color.ink.opacity(0.72))
            //         Spacer()
            //         if !vm.sleepCountdown.isEmpty {
            //             Label(vm.sleepCountdown, systemImage: "moon.zzz.fill")
            //                 .font(.system(size: 12, weight: .semibold, design: .rounded))
            //                 .foregroundStyle(Color.selectedColor)
            //         }
            //     }
            // }

            if vm.anyActive {
                HStack(spacing: 18) {
                    ControlButton(
                        symbol: "slider.horizontal.3",
                        // label:"选项",
                        disabled: !vm.anyActive,
                    ) {
                        showSoundSettingsPicker = true
                    }

                    Divider().frame(height: 32).opacity(0.2)

                    // 播放 / 暂停
                    ControlButton(
                        symbol: vm.isPlaying ? "pause.fill" : "play.fill",
                        // label: vm.isPlaying ? "暂停" : "播放",
                        disabled: !vm.anyActive
                    ) { vm.togglePlayPause() }

                    ControlButton(
                        symbol: "moon.zzz.fill",
                        // label: "定时",
                        disabled: !vm.anyActive
                    ) {
                        showSleepPicker.toggle()
                    }

                    // ControlButton(
                    //     symbol: "square.stack.3d.up",
                    //     label: "混合库"
                    // ) {
                    //     showMixLibrary = true
                    // }

                    // 睡眠定时器
                    // Button {
                    //     showSleepPicker.toggle()
                    // } label: {
                    //     VStack(spacing: 4) {
                    //         Image(systemName: "moon.zzz.fill")
                    //             .font(.system(size: 18, weight: .semibold))
                    //             .foregroundStyle(vm.sleepCountdown.isEmpty ? Color.ink.opacity(0.58) : Color.selectedColor)
                    //         Text(vm.sleepCountdown.isEmpty ? "定时" : vm.sleepCountdown)
                    //             .font(.system(size: 10, weight: .semibold, design: .rounded))
                    //             .foregroundStyle(vm.sleepCountdown.isEmpty ? Color.ink.opacity(0.58) : Color.selectedColor)
                    //     }
                    //     .frame(maxWidth: .infinity)
                    //     .padding(.vertical, 14)
                    //     .background(
                    //         RoundedRectangle(cornerRadius: 20, style: .continuous)
                    //             .fill(Color.white.opacity(0.56))
                    //     )
                    // }
                    // .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(8)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.panel.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 12)
        .sheet(isPresented: $showSleepPicker) {
            SleepTimerSheet()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSoundSettingsPicker) {
            SoundSettingsView()
        }
        .sheet(isPresented: $showMixLibrary) {
            MixLibraryView()
        }
    }
}

// MARK: - ControlButton

private struct ControlButton: View {
    let symbol: String
    // let label: String
    var disabled: Bool = false
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        disabled ? Color(.tertiaryLabel) :
                            destructive ? Color.red :
                            Color.selectedColor
                    )
                // Text(label)
                //     .font(.system(size: 10, weight: .semibold, design: .rounded))
                //     .foregroundStyle(disabled ? Color(.tertiaryLabel) : Color.ink.opacity(0.66))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(disabled ? Color.white.opacity(0.35) : Color.white.opacity(0.62))
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}

// MARK: - SleepTimerSheet

struct SleepTimerSheet: View {
    @EnvironmentObject var vm: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    private let options: [Double] = [15, 30, 45, 60, 90, 120]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sleep Timer")

                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                .padding(.top, 8)

            // 快捷选项
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 10) {
                ForEach(options, id: \.self) { min in
                    let selected = vm.sleepMinutes == min
                    Button {
                        vm.sleepMinutes = min
                        vm.startSleepTimer()
                        dismiss()
                    } label: {
                        Text("\(Int(min)) min")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selected ? Color.selectedColor : Color.secondary.opacity(0.12))
                            .foregroundStyle(selected ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            // 取消定时
            if !vm.sleepCountdown.isEmpty {
                Button(role: .destructive) {
                    vm.cancelSleepTimer()
                    dismiss()
                } label: {
                    Label(
                        "Cancel Timer (\(vm.sleepCountdown) Left)",
                        systemImage: "xmark.circle"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }
}
