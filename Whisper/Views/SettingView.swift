//
//  SettingView.swift
//  Whisper
//
//  Created by luckly on 2026/1/22.
//  使用 value 导航 + navigationDestination，子页仅在点击时创建。
//

import SwiftUI
import StoreKit

private enum SettingsRoute: Hashable {
    case theme
    case language
    case about
}

struct SettingView: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: SettingsRoute.theme) {
                        SettingsRow(icon: "paintbrush.fill", title: "主题颜色", detail: ThemeManager.shared.getThemeDisplayName())
                    }

                    NavigationLink(value: SettingsRoute.language) {
                        SettingsRow(icon: "globe", title: "语言", detail: LanguageManager.shared.currentLanguage.displayName)
                    }
                } header: {
                    Text("通用")
                }

                Section {
                    Button {
                        requestReview()
                    } label: {
                        SettingsRow(icon: "star.fill", title: "给应用评分", detail: nil)
                    }
                    .foregroundStyle(.primary)

                    Link(destination: AppConfig.privacyPolicyURL) {
                        SettingsRow(icon: "hand.raised.fill", title: "隐私政策", detail: nil)
                    }
                    .foregroundStyle(.primary)

                    Link(destination: AppConfig.termsOfServiceURL) {
                        SettingsRow(icon: "doc.text.fill", title: "用户协议", detail: nil)
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("支持")
                }

                Section {
                    NavigationLink(value: SettingsRoute.about) {
                        SettingsRow(icon: "info.circle.fill", title: "关于", detail: "v\(AppConfig.appVersion)")
                    }
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .theme:
                    ThemeMangerView()
                case .language:
                    LanguageManagerView()
                case .about:
                    AboutView()
                }
            }
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let title: String
    let detail: String?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.appTheme)
                .frame(width: 24, alignment: .center)
            Text(title)
                .foregroundStyle(.primary)
            if let detail {
                Spacer()
                Text(detail)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
