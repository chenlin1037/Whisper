//
//  Collection.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/5/7.
//

import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var vm: PlayerViewModel
    @EnvironmentObject var collectionStore: CollectionStore

    private enum Layout {
        static let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        static let spacing: CGFloat = 14
        static let horizontalPadding: CGFloat = 16
    }

    private var collectedSoundsResolved: [Sound] {
        collectionStore.collectedSounds.compactMap { vm.soundsByID[$0.soundID] }
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // header

                    if collectionStore.collectedSounds.isEmpty {
                        emptyState
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                    } else {
                        LazyVGrid(columns: Layout.columns, spacing: Layout.spacing) {
                            ForEach(collectedSoundsResolved) { sound in
                                SoundCardView(sound: sound)
                            }
                        }
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, vm.anyActive ? 130 : 36)
            }
            .scrollIndicators(.hidden)

            if vm.anyActive {
                ControlBarView(vm: vm)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    // private var header: some View {
    //     VStack(alignment: .leading, spacing: 8) {
    //         Text("我的收藏")
    //             .font(.system(size: 24, weight: .bold, design: .rounded))
    //             .foregroundStyle(Color.ink)

    //         Text(summaryText)
    //             .font(.system(size: 14, weight: .medium, design: .rounded))
    //             .foregroundStyle(Color.ink.opacity(0.62))
    //     }
    //     .padding(.horizontal, 4)
    // }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 52, weight: .regular))
                .foregroundStyle(Color.selectedColor.opacity(0.75))

            VStack(spacing: 6) {
                Text("No Favorites Yet")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text("Tap the heart icon in the top-right corner of a sound card to add your favorite sounds here.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.ink.opacity(0.56))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 30)
            }
        }
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        )
    }

    // private var summaryText: String {
    //     let count = vm.collectedSounds.count
    //     return count == 0 ? "把喜欢的声音放在手边" : "\(count) 个常用声音"
    // }
}
