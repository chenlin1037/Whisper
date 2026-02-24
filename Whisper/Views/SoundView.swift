//
//  SoundView.swift
//  GoodSleep
//
//  Created by luckly on 2026/1/23.
//  Explicit Data Flow Version with Category Support
//  Updated: 2026/2/5 - 添加左右滑动切换分类功能
//

import SwiftUI
import UIKit

// MARK: - 图标显示：优先使用 SwiftUI Image 避免 UIImage(named:) 的系统缓存膨胀

struct SoundView: View {
    // MARK: - State

    @StateObject private var soundVM = SoundViewModel()
    @StateObject private var playingBarVM = PlayingBarViewModel()
    @ObservedObject private var sleepTimerVM = SleepTimerViewModel.shared

    @State private var showSleepTimer = false
    @State private var showSoundSettings = false
    @State private var selectedSound: Sound?
    @State private var selectedCategoryIndex: Int = 0 // 改用索引以配合 TabView
    @State private var showSearch = false // 显示搜索视图

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
        static let cornerRadius: CGFloat = 16
        static let categoryHeight: CGFloat = 44
        static let searchBarHeight: CGFloat = 52
    }

    // MARK: - Computed Properties

    /// 获取所有分类（包括"全部"）
    private var categories: [String] {
        let cats = Set(soundVM.sounds.map { $0.category })
        var result = ["全部"]
        result.append(contentsOf: cats.sorted())
        return result
    }

    /// 当前选中的分类名称
    private var selectedCategory: String {
        guard selectedCategoryIndex < categories.count else { return "全部" }
        return categories[selectedCategoryIndex]
    }

    /// 根据索引获取过滤后的声音
    private func soundsForCategory(at index: Int) -> [Sound] {
        guard index < categories.count else { return soundVM.sounds }
        let category = categories[index]
        if category == "全部" {
            return soundVM.sounds
        }
        return soundVM.sounds.filter { $0.category == category }
    }

    /// 按分类分组的列表（不含「全部」），用于单列表分段展示
    private var soundsGroupedByCategory: [(category: String, sounds: [Sound])] {
        let cats = categories.filter { $0 != "全部" }
        return cats.map { cat in
            (category: cat, sounds: soundVM.sounds.filter { $0.category == cat })
        }
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

                // 底部控制区：剩余时间 + 播放控制条
                VStack(spacing: 0) {
                    if sleepTimerVM.isTimerActive {
                        HStack(spacing: 6) {
                            Text(sleepTimerVM.formattedRemainingTime)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.appTheme.opacity(0.12))
                        )
                        .padding(.bottom, 8)
                    }

                    // 🎧 播放控制条
                    PlayingBarView(
                        viewModel: playingBarVM,
                        onTogglePlayPause: { shouldPlay in
                            if shouldPlay {
                                soundVM.playAll()
                            } else {
                                soundVM.pauseAll()
                            }
                        },
                        onShowSleepTimer: {
                            showSleepTimer = true
                        },
                        onShowSoundSettings: { sound in
                            selectedSound = sound
                            showSoundSettings = true
                        }
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView(allSounds: soundVM.sounds) { sound in
                soundVM.toggle(sound: sound)
            }
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var content: some View {
        switch (soundVM.isLoading, soundVM.errorMessage) {
        case (true, _):
            ProgressView()
                .scaleEffect(1.2)

        case (false, let .some(error)):
            errorView(message: error)

        case (false, .none):
            VStack(spacing: 0) {
                searchBarPlaceholder
                categoryBar
                soundGridPager
            }
        }
    }

    // MARK: - Search Bar Placeholder (点击后进入搜索视图)

    private var searchBarPlaceholder: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))

            Text("搜索声音")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, Layout.horizontalPadding)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .onTapGesture {
            showSearch = true
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("重试", action: { soundVM.loadSounds() })
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.appTheme)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Category Bar

    private var categoryBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                        CategoryChip(
                            title: category,
                            isSelected: selectedCategoryIndex == index,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCategoryIndex = index
                                }
                            }
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.vertical, 8)
            }
            .frame(height: Layout.categoryHeight)
            .background(.ultraThinMaterial)
            .onChange(of: selectedCategoryIndex) { oldValue,newIndex in
                // 自动滚动到选中的分类
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    // MARK: - 单列表分段展示（不因切换分类而重建，避免内存持续增长）

    /// 始终使用同一个 ScrollView，通过滚动到目标 section 切换分类，避免 view 重建导致的内存泄漏
    private var soundGridPager: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // 全部
                    sectionHeader("全部")
                        .id("全部")
                    soundGrid(soundVM.sounds)

                    // 各分类
                    ForEach(soundsGroupedByCategory, id: \.category) { group in
                        sectionHeader(group.category)
                            .id(group.category)
                        soundGrid(group.sounds)
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.topPadding)
                .padding(.bottom, 32)
            }
            .onChange(of: selectedCategoryIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    let id = newIndex == 0 ? "全部" : categories[newIndex]
                    proxy.scrollTo(id, anchor: .top)
                }
            }
            .onAppear {
                if selectedCategoryIndex > 0 {
                    let id = categories[selectedCategoryIndex]
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 4)
    }

    private func soundGrid(_ sounds: [Sound]) -> some View {
        LazyVGrid(columns: Layout.columns, spacing: Layout.gridSpacing) {
            ForEach(sounds) { sound in
                SoundCard(
                    sound: sound,
                    size: Layout.cardSize,
                    iconSize: Layout.iconSize,
                    onTap: { soundVM.toggle(sound: sound) }
                )
            }
        }
    }
}

// MARK: - Category Chip Component

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Text(title)
            .font(.system(size: isSelected ? 16 : 14, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .onTapGesture {
                feedbackGenerator.impactOccurred()
                onTap()
            }
            .onAppear {
                feedbackGenerator.prepare()
            }
    }
}

// MARK: - 直接使用 SwiftUI Image，按 frame 尺寸渲染，避免 UIImage(named:) 全量解码进系统缓存

struct DownsampledAssetImage: View {
    let assetName: String
    let pointSize: CGFloat
    var isPlaying: Bool = false
    var colorScheme: ColorScheme = .light

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: pointSize, height: pointSize)
            .brightness(isPlaying ? 0 : (colorScheme == .dark ? 0.06 : 0))
    }
}

// MARK: - Sound Card Component

struct SoundCard: View {
    let sound: Sound
    let size: CGFloat
    let iconSize: CGFloat
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                DownsampledAssetImage(
                    assetName: sound.icon,
                    pointSize: iconSize,
                    isPlaying: sound.isPlaying,
                    colorScheme: colorScheme
                )
            }
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(cardBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(cardBorderColor, lineWidth: colorScheme == .dark && !sound.isPlaying ? 0.5 : 0)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)

            Text(sound.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    sound.isPlaying ? .primary : .secondary
                )
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            feedbackGenerator.prepare()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: sound.isPlaying)
    }

    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }

        feedbackGenerator.impactOccurred()
        onTap()
    }

    private var cardBackgroundColor: Color {
        if sound.isPlaying {
            return Color.appTheme
        }
        return Color.appTheme.opacity(0.6)
    }

    private var cardBorderColor: Color {
        Color.primary.opacity(0.08)
    }
}

// MARK: - Preview

#Preview {
    SoundView()
}
