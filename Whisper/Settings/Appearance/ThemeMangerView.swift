//
//  ThemeMangerView.swift
//  Doone
//
//  Created by luckly on 2026/1/15.
//

import SwiftUI

struct ThemeMangerView: View {
    @Environment(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(themeManager.getAllThemes(), id: \.self) { theme in
                ThemeOptionRow(
                    theme: theme,
                    isSelected: themeManager.currentTheme == theme
                ) {
                    themeManager.setTheme(theme)
                    dismiss()
                }
            }
        }
        .navigationTitle(String(localized: "主题颜色"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ThemeOptionRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)

                    Text(themeDescription(for: theme))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.appTheme)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .system:
            return String(localized: "theme_system_description")
        case .light:
            return String(localized: "theme_light_description")
        case .dark:
            return String(localized: "theme_dark_description")
        }
    }
}

#Preview {
    ThemeMangerView()
}
