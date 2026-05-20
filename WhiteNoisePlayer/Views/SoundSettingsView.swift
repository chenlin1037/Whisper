//
//  SoundSettingsView.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/5/1.
//

// 声音设置：各部分的音量

import SwiftUI
import WhiteNoiseSDK

struct SoundSettingsView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @State private var showSaveMixSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    listContent // ✅ 使用计算属性来处理条件渲染
                }

                Spacer()

                SleepTimerSheet()
            }

            .listStyle(.insetGrouped)
            .navigationTitle("Sound Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSaveMixSheet) {
                SaveMixSheetView(showSaveMixSheet: $showSaveMixSheet)
            }
        }
    }

    // ✅ 将条件逻辑放入计算属性
    @ViewBuilder
    private var listContent: some View {
        if vm.anyActive {
            Section {
                ForEach(Array(vm.activeTracks.values)) { track in
                    VolumeSliderRow(track: track, engine: WhiteNoiseEngine.shared)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
            } header: {
                Text("Active Sounds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(nil)

            } footer: {
                Button {
                    showSaveMixSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save as Mix")
                    }
                    .frame(maxWidth: .infinity)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.selectedColor)
                }
                .padding(.top, 8)
            }
        } else {
            EmptyTrackView()
        }
    }
}

// SaveMixSheetView

struct SaveMixSheetView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @EnvironmentObject var mixLibraryStore: MixLibraryStore
    @State private var newMixName = ""
    @Binding var showSaveMixSheet: Bool
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mix Name")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.5)

                    TextField("e.g. Focus Work", text: $newMixName)
                        .focused($isTextFieldFocused)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .submitLabel(.done)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(.tertiarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            isTextFieldFocused
                                                ? Color.selectedColor.opacity(0.6)
                                                : Color(.separator).opacity(0.4),
                                            lineWidth: isTextFieldFocused ? 1.5 : 1
                                        )
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Text("This will save \(vm.activeTracks.count) sounds and their current volume levels")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("Save Mix")
            .navigationBarTitleDisplayMode(.inline)
            // .onAppear {
            //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //         isTextFieldFocused = true
            //     }
            // }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = false
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newMixName = ""
                        showSaveMixSheet = false
                    }
                    .foregroundStyle(Color.selectedColor)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !newMixName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            let name = newMixName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let items = vm.currentMixItems()

                            mixLibraryStore.add(name: name, items: items)
                            newMixName = ""
                            showSaveMixSheet = false
                        }
                    }
                    .foregroundStyle(Color.selectedColor)
                    .disabled(newMixName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - VolumeSliderRow

struct VolumeSliderRow: View {
    @ObservedObject var track: AudioTrack
    let engine: WhiteNoiseEngine
    let allSounds = SoundDataManager.shared.sounds

    // 本地显示值，跟随手势实时更新（不触发引擎）
    @State private var localVolume: Double
    // 防抖任务句柄
    @State private var debounceTask: DispatchWorkItem?

    init(track: AudioTrack, engine: WhiteNoiseEngine) {
        self.track = track
        self.engine = engine
        _localVolume = State(initialValue: Double(track.volume))
    }

    private var sound: Sound? {
        allSounds.first { $0.id == track.id }
    }

    private var displayName: String {
        sound?.name ?? track.id
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()

            Slider(value: $localVolume, in: 0 ... 1)
                .onChange(of: localVolume) { oldValue, newValue in
                    scheduleVolumeUpdate(newValue)
                }

            Text("\(Int(localVolume * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(minWidth: 36, alignment: .trailing)
        }
        // 外部（如切换 Mix）改变 track.volume 时同步本地值
        .onChange(of: track.volume) { oldValue, newValue in
            let v = Double(newValue)
            // 只在差距明显时才同步，避免和防抖产生循环
            if abs(v - localVolume) > 0.005 {
                localVolume = v
            }
        }
    }

    private func scheduleVolumeUpdate(_ value: Double) {
        // 取消上一个待执行的任务
        debounceTask?.cancel()

        let task = DispatchWorkItem {
            engine.setVolume(Float(value), for: track.id, fade: 0.1)
        }
        debounceTask = task

        // 100ms 后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: task)
    }
}

// MARK: - EmptyTrackView

struct EmptyTrackView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.slash")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.tertiary)

            VStack(spacing: 4) {
                Text("No Active Sounds")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Text("Start playing sounds to adjust individual volume levels here")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .listRowBackground(Color.clear)
    }
}
