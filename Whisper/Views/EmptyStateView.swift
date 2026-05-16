//
//  EmptyStateView.swift
//  Whisper
//
//  简洁空状态：图标 + 标题 + 说明，遵循主题色与系统风格。
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.appTheme.opacity(0.8))

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyStateView(
        icon: "heart",
        title: "收藏",
        message: "收藏的声音将显示在这里。"
    )
}
