//
//  MixSoundView.swift
//  Whisper
//
//  Created by luckly on 2026/2/10.
//

import SwiftUI
import UIKit

struct MixSoundView: View {
    // MARK: - State

    @EnvironmentObject private var viewModel: MixSoundViewModel
    @StateObject private var playingBarVM = PlayingBarViewModel()

    @State private var showCreateMix = false
    @State private var showEditMix = false
    @State private var showMixDetail: MixSound?

    // MARK: - Constants

    private enum Layout {
        static let columns: [GridItem] = Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: 4
        )
        static let cardSize: CGFloat = 80
        static let iconSize: CGFloat = 48
        static let gridSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 16
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    content
                }

                // 播放控制条
                PlayingBarView(
                    viewModel: playingBarVM,
                    onTogglePlayPause: { shouldPlay in
                        if shouldPlay {
                            AllSoundManger.shared.playAll()
                        } else {
                            AllSoundManger.shared.pauseAll()
                        }
                    },
                    onShowSleepTimer: {},
                    onShowSoundSettings: { _ in }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationTitle("混合")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.startCreating()
                        showCreateMix = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.appTheme)
                    }
                }
            }
            .sheet(isPresented: $showCreateMix) {
                createEditMixSheet()
            }
            .sheet(item: $showMixDetail) { mix in
                mixDetailSheet(mix: mix)
            }
        }
        .onAppear {
//            playingBarVM.updateSounds(AllSoundManger.shared.sounds)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.mixes.isEmpty {
            EmptyStateView(
                icon: "slider.horizontal.3",
                title: "混合",
                message: "点击右上角 + 创建你的第一个声音混合。"
            )
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.mixes) { mix in
                        MixCard(
                            mix: mix,
                            sounds: viewModel.soundsForMix(mix),
                            onPlay: {
                                viewModel.play(mix)
                            },
                            onEdit: {
                                viewModel.startEditing(mix)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showCreateMix = true
                                }
                            },
                            onDetail: {
                                showMixDetail = mix
                            },
                            onDelete: {
                                viewModel.delete(mix)
                            },
                            onTogglePin: {
                                viewModel.togglePin(mix)
                            }
                        )
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.topPadding)
                .padding(.bottom, 100)
            }
        }
    }

    // MARK: - Create/Edit Mix Sheet

    @ViewBuilder
    private func createEditMixSheet() -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 输入名称
                VStack(alignment: .leading, spacing: 8) {
                    Text("混合名称")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    TextField("例如：工作专注", text: $viewModel.newMixName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 16)

                // 声音选择
                ScrollView {
                    LazyVGrid(columns: Layout.columns, spacing: Layout.gridSpacing) {
                        ForEach(viewModel.allSounds) { sound in
                            MixSelectionCard(
                                sound: sound,
                                size: Layout.cardSize,
                                iconSize: Layout.iconSize,
                                isSelected: viewModel.isSelected(sound),
                                onTap: {
                                    viewModel.toggleSelection(sound)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.top, Layout.topPadding)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(viewModel.isEditing ? "编辑混合" : "创建混合")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        viewModel.cancelEditing()
                        showCreateMix = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.saveMix()
                        showCreateMix = false
                    }
                    .disabled(viewModel.newMixName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.selectedSoundStableIDs.isEmpty)
                }
            }
        }
    }

    // MARK: - Mix Detail Sheet

    @ViewBuilder
    private func mixDetailSheet(mix: MixSound) -> some View {
        NavigationStack {
            List {
                ForEach(viewModel.soundsForMix(mix), id: \.0.stableID) { sound, savedVolume in
                    MixDetailSoundRow(
                        sound: sound,
                        savedVolume: savedVolume,
                        onVolumeChange: { newVolume in
                            viewModel.updateMixSoundVolume(mix: mix, stableID: sound.stableID, volume: newVolume)
                        },
                        onTogglePlaying: {
                            viewModel.toggleMixSoundPlaying(mix: mix, stableID: sound.stableID)
//                            playingBarVM.updateSounds(AllSoundManger.shared.sounds)
                        },
                        onRemove: {
                            viewModel.removeSoundFromMix(mix: mix, stableID: sound.stableID)
                        }
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(mix.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        showMixDetail = nil
                    }
                }
            }
        }
    }
}

// MARK: - Mix Card

struct MixCard: View {
    let mix: MixSound
    let sounds: [(Sound, Double)]
    let onPlay: () -> Void
    let onEdit: () -> Void
    let onDetail: () -> Void
    let onDelete: () -> Void
    let onTogglePin: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 12) {
            // 播放按钮
            Button {
                HapticFeedback.impact(style: .medium)
                onPlay()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.appTheme)
                        .frame(width: 44, height: 44)

                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            // 信息（可点击进入详情）
            Button {
                onDetail()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mix.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(sounds.count) 个声音")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // 置顶按钮
            Button {
                HapticFeedback.impact(style: .light)
                onTogglePin()
            } label: {
                Image(systemName: mix.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 16))
                    .foregroundStyle(mix.isPinned ? Color.appTheme : .secondary)
                    .padding(8)
            }
            .accessibilityLabel(mix.isPinned ? String(localized: "取消置顶") : String(localized: "置顶"))

            // 编辑按钮
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }

            // 删除按钮
            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .alert("删除混合", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("确定要删除「\(mix.name)」吗？")
        }
    }
}

// MARK: - Mix Detail Sound Row

struct MixDetailSoundRow: View {
    let sound: Sound
    let savedVolume: Double
    let onVolumeChange: (Double) -> Void
    let onTogglePlaying: () -> Void
    let onRemove: () -> Void

    @State private var currentVolume: Double

    init(sound: Sound, savedVolume: Double, onVolumeChange: @escaping (Double) -> Void, onTogglePlaying: @escaping () -> Void, onRemove: @escaping () -> Void) {
        self.sound = sound
        self.savedVolume = savedVolume
        self.onVolumeChange = onVolumeChange
        self.onTogglePlaying = onTogglePlaying
        self.onRemove = onRemove
        _currentVolume = State(initialValue: savedVolume)
    }

    var body: some View {
        HStack(spacing: 12) {
            // 播放/暂停按钮
            Button {
                HapticFeedback.impact(style: .light)
                onTogglePlaying()
            } label: {
                Image(systemName: sound.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(sound.isPlaying ? Color.appTheme : .secondary)
            }
            .buttonStyle(.plain)

            Text(sound.name)
                .font(.body)

            Spacer()

            // 音量滑块
            Slider(value: Binding(
                get: { currentVolume },
                set: { newValue in
                    currentVolume = newValue
                    sound.volume = newValue
                    AudioPlayerManager.shared.updateVolume(for: sound)
                    onVolumeChange(newValue)
                }
            ), in: 0 ... 1)
                .frame(width: 120)

            Text("\(Int(currentVolume * 100))")
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 32, alignment: .trailing)

            // 移除按钮
            Button {
                HapticFeedback.impact(style: .light)
                onRemove()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .onChange(of: savedVolume) { oldValue,newValue in
            currentVolume = newValue
        }
    }
}

// MARK: - Mix Selection Card

struct MixSelectionCard: View {
    let sound: Sound
    let size: CGFloat
    let iconSize: CGFloat
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                DownsampledAssetImage(
                    assetName: sound.icon,
                    pointSize: iconSize,
                    isPlaying: false,
                    colorScheme: colorScheme
                )

                // 选中标记
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.appTheme)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                )
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.appTheme.opacity(0.3) : Color.appTheme.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.appTheme : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)

            Text(sound.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            HapticFeedback.impact(style: .light)
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


