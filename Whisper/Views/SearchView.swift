//
//  SearchView.swift
//  Whisper
//
//  Created by luckly on 2026/2/6.
//

//
//  SearchView.swift
//  GoodSleep
//
//  Created on 2026/2/6
//  搜索功能 - 视图
//

import SwiftUI

struct SearchView: View {
    // MARK: - Properties

    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFieldFocused: Bool

    /// 从父视图传入的所有声音数据
    let allSounds: [Sound]

    /// 点击声音的回调
    let onSoundTap: (Sound) -> Void

    // MARK: - Constants

    private enum Layout {
        static let columns: [GridItem] = Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: 4
        )
        static let cardSize: CGFloat = 80
        static let iconSize: CGFloat = 48
    }

    // MARK: - Initialization

    init(allSounds: [Sound], onSoundTap: @escaping (Sound) -> Void) {
        self.allSounds = allSounds
        self.onSoundTap = onSoundTap
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏
                searchBar

                Divider()

                // 内容区域
                contentView
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarLeading) {
            //         Button {
            //             dismiss()
            //         } label: {
            //             HStack(spacing: 4) {
            //                 Image(systemName: "chevron.left")
            //                     .font(.system(size: 16, weight: .semibold))
            //                 Text("返回")
            //                     .font(.system(size: 16))
            //             }
            //             .foregroundStyle(.primary)
            //         }
            //     }
            // }
            .onAppear {
                viewModel.setSounds(allSounds)
                // 自动聚焦搜索框
                isSearchFieldFocused = true
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))

                TextField("搜索声音", text: $viewModel.searchText)
                    .focused($isSearchFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.performSearch()
                    }

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isSearching {
            loadingView
        } else if !viewModel.searchText.isEmpty {
            searchResultsView
        } else {
            searchSuggestionsView
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("搜索中...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Search Results View

    private var searchResultsView: some View {
        Group {
            if viewModel.searchResults.isEmpty {
                emptyResultsView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("找到 \(viewModel.searchResults.count) 个结果")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                        LazyVGrid(columns: Layout.columns, spacing: 12) {
                            ForEach(viewModel.searchResults) { sound in
                                SoundCard(
                                    sound: sound,
                                    size: Layout.cardSize,
                                    iconSize: Layout.iconSize,
                                    onTap: {
                                        onSoundTap(sound)
                                        dismiss()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("未找到相关声音")
                .font(.headline)

            Text("试试搜索其他关键词")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Search Suggestions View

    private var searchSuggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 搜索历史
                if !viewModel.searchHistory.isEmpty {
                    searchHistorySection
                }
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - Search History Section

    private var searchHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("搜索历史")
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        viewModel.clearAllHistory()
                    }
                } label: {
                    Text("清空")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(viewModel.searchHistory, id: \.self) { text in
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)

                        Text(text)
                            .font(.body)

                        Spacer()

                        Button {
                            withAnimation {
                                viewModel.removeFromHistory(text)
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.searchWithHistory(text)
                    }

                    if text != viewModel.searchHistory.last {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Flow Layout (流式布局)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))

                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

// MARK: - Preview
