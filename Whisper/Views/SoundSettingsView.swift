//
//  SoundSettingsView.swift
//  Whisper
//
//  声音设置：调节总音量及混合声音各部分的音量
//

import SwiftUI

struct SoundSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var soundManager = AllSoundManger.shared
    @ObservedObject private var audioManager = AudioPlayerManager.shared
    @EnvironmentObject private var mixSoundVM: MixSoundViewModel

    @State private var showSaveMixSheet = false
    @State private var newMixName = ""

    private var playingSounds: [Sound] {
        soundManager.sounds.filter { $0.isPlaying }
    }

    private var canSaveAsMix: Bool {
        !playingSounds.isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                // 总音量
                Section {
                    HStack(spacing: 12) {
                        Text("总音量")
                            .font(.body)

                        Spacer()

                        Slider(value: Binding(
                            get: { audioManager.masterVolume },
                            set: { audioManager.masterVolume = max(0, min(1, $0)) }
                        ), in: 0 ... 1)
                            .frame(width: 180)

                        Text("\(Int(audioManager.masterVolume * 100))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .frame(width: 32, alignment: .trailing)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                // 各声音音量
                if !playingSounds.isEmpty {
                    Section {
                        ForEach(playingSounds) { sound in
                            SoundVolumeRow(sound: sound)
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        }
                    } header: {
                        Text("混合声音")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                    } footer: {
                        if canSaveAsMix {
                            Button {
                                showSaveMixSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("保存为混合")
                                }
                                .frame(maxWidth: .infinity)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.appTheme)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("声音设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showSaveMixSheet) {
                saveMixSheet
            }
        }
        .tint(Color.appTheme)
    }

    // MARK: - Save Mix Sheet

    private var saveMixSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("混合名称")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    TextField("例如：工作专注", text: $newMixName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Text("将保存 \(playingSounds.count) 个声音及其当前音量设置")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("保存为混合")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        newMixName = ""
                        showSaveMixSheet = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if !newMixName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            mixSoundVM.createMixFromCurrentState(name: newMixName.trimmingCharacters(in: .whitespacesAndNewlines))
                            newMixName = ""
                            showSaveMixSheet = false
                        }
                    }
                    .disabled(newMixName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - 单条声音音量行

private struct SoundVolumeRow: View {
    let sound: Sound
    @ObservedObject private var soundManager = AllSoundManger.shared

    var body: some View {
        HStack(spacing: 12) {
            // Image(sound.icon) // 自定义图标
            //     .resizable()
            //     .scaledToFit()
            //     .frame(width: 32, height: 32)
            //     .clipShape(RoundedRectangle(cornerRadius: 6))
            //     // 背景颜色为主题色
            //     .background(Color.appTheme)
            //     .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(sound.name)
                .font(.body)

            Spacer()

            Slider(value: Binding(
                get: { sound.volume },
                set: { newValue in
                    sound.volume = max(0, min(1, newValue))
                    AudioPlayerManager.shared.updateVolume(for: sound)
                    soundManager.objectWillChange.send()
                }
            ), in: 0 ... 1)
                .frame(width: 180)

            Text("\(Int(sound.volume * 100))")
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 32, alignment: .trailing)
        }
    }
}

#Preview {
    SoundSettingsView()
        .environmentObject(MixSoundViewModel())
}
