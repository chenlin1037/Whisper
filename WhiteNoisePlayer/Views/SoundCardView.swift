//
//  SoundCardView.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

// MARK: - File: SoundCardView.swift

import SwiftUI
import WhiteNoiseSDK

struct SoundCardView: View {
    let sound: Sound
    @EnvironmentObject var vm: PlayerViewModel
    @EnvironmentObject var collectionStore: CollectionStore

    private enum Layout {
        static let contentHeight: CGFloat = 120
        static let cardPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 26
        static let borderWidth: CGFloat = 1
        static let shadowRadius: CGFloat = 14
        static let shadowY: CGFloat = 8
    }

    private var active: Bool { vm.isActive(sound.id) }
    private var loading: Bool { vm.isLoading(sound.id) }
    private var track: AudioTrack? { vm.track(for: sound.id) }
    private var collected: Bool { collectionStore.contains(soundID: sound.id) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Button {
                vm.toggle(sound)
            } label: {
                cardContent
            }
            .buttonStyle(.plain)
            .disabled(loading)

            heartButton
        }
    }

    // MARK: Sub-views

    private var heartButton: some View {
        Button {
            collectionStore.toggle(soundID: sound.id)
        } label: {
            Image(systemName: collected ? "heart.fill" : "heart")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(collected ? Color.red : Color.ink.opacity(0.45))
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle().stroke(Color.white.opacity(0.65), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                iconView
                // Spacer(minLength: 8)

                statusIcon
                    .padding(.trailing, 8)
            }
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(sound.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(active ? Color.selectedColor : Color.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)

                    Text(sound.category.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(active ? Color.selectedColor : Color.ink.opacity(0.45))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: Layout.contentHeight)
        .padding(Layout.cardPadding)
        .background(cardBackground)
        .overlay(activeBorder)
        .shadow(
            color: shadowColor,
            radius: Layout.shadowRadius,
            x: 0,
            y: Layout.shadowY
        )
    }

    @ViewBuilder
    private var statusIcon: some View {
        if loading {
            ProgressView()
                .controlSize(.small)
                .tint(Color.selectedColor)
        } else if active {
            Image(systemName: "waveform")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.selectedColor)
        }
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackground)
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
            SoundIcon(symbol: sound.symbol)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
            .fill(active ? Color.white.opacity(0.92) : Color.cardBase)
    }

    private var iconBackground: LinearGradient {
        LinearGradient(
            colors: active
                ? [Color.selectedColor, Color.accent]
                : [Color.accent, Color.mist],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var shadowColor: Color {
        Color.black.opacity(0.08)
    }

    private var activeBorder: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
            .strokeBorder(
                active ? Color.white.opacity(0.95) : Color.white.opacity(0.72),
                lineWidth: Layout.borderWidth
            )
    }
}

struct SoundIcon: View {
    let symbol: String

    // 在 init 里判断一次，结果缓存为常量，body 里不再做 I/O
    private let isSystemSymbol: Bool

    init(symbol: String) {
        self.symbol = symbol
        isSystemSymbol = UIImage(systemName: symbol) != nil
    }

    var body: some View {
        if isSystemSymbol {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
        } else {
            Image(symbol)
                .resizable()
                .scaledToFit()
        }
    }
}
