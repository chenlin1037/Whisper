import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSeleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: isSeleted ? .semibold : .medium, design: .rounded))
                .foregroundStyle(isSeleted ? .white : Color.ink.opacity(0.78))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSeleted ? Color.selectedColor : Color.panel)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSeleted ? Color.white.opacity(0.65) : Color.white.opacity(0.9), lineWidth: 1)
                )
                .shadow(
                    color: isSeleted ? Color.selectedColor.opacity(0.22) : Color.white.opacity(0.45),
                    radius: isSeleted ? 14 : 10,
                    x: 0,
                    y: isSeleted ? 8 : 4
                )
                .scaleEffect(isSeleted ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSeleted)
        }
        .buttonStyle((.plain)) // 自定义按压效果
    }
}


