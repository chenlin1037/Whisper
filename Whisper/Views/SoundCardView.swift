//
//  SoundCardView.swift
//  GoodSleep
//
//  Created by luckly on 2026/3/8.
//

import SwiftUI

struct SoundCardView: View {
    let sound: Sound
    let size: CGFloat
    let iconSize: CGFloat
    var isFavorite: Bool = false
    let onTap: () -> Void
    var onToggleFavorite: (() -> Void)? = nil

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
            .overlay(alignment: .topTrailing) {
                if let onToggleFavorite {
                    Button {
                        HapticFeedback.impact(style: .light)
                        onToggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundStyle(isFavorite ? Color.red : .secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(6)
                }
            }
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
