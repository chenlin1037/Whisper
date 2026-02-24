//
//  MainTabView.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//

import SwiftUI
import StoreKit

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var mixSoundViewModel = MixSoundViewModel()
    @Environment(\.requestReview) private var requestReview

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                SoundView()
                    .tabItem { Label("声音", systemImage: "music.note.list") }
                    .tag(0)

                MixSoundView()
                    .environmentObject(mixSoundViewModel)
                    .tabItem { Label("混合", systemImage: "scribble.variable") }
                    .tag(1)

                SettingView()
                    .tabItem { Label("设置", systemImage: "gear.circle") }
                    .tag(2)
            }
        }
        .environmentObject(mixSoundViewModel)
        .accentColor(.appTheme)
        .onChange(of: selectedTab) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        .task {
            AppLaunchHandler.handleLaunch(requestReview: { requestReview() })
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

        // 集中设置样式
        let itemAppearance = appearance.stackedLayoutAppearance
        itemAppearance.selected.iconColor = UIColor.appTheme
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appTheme]
        itemAppearance.normal.iconColor = UIColor.secondaryLabel
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
