//
//  MainTabView.swift
//  Whisper
//

import SwiftUI
import StoreKit

struct MainTabView: View {
    @State private var selectedTab = 0

    // ✅ 使用自定义 init 初始化 StateObject（关键）
    @StateObject private var mixSoundViewModel: MixSoundViewModel

    // MARK: - Init

    init() {
        

        // ✅ 所有 @MainActor 单例在这里创建（安全）
        let soundManager = AllSoundManger.shared
        let mixService = MixSoundService(soundManager: soundManager)

        _mixSoundViewModel = StateObject(
            wrappedValue: MixSoundViewModel(
                mixService: mixService,
                soundManager: soundManager
            )
        )
        
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
    }

    // MARK: - UI

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

        let itemAppearance = appearance.stackedLayoutAppearance
        itemAppearance.selected.iconColor = UIColor.appTheme
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appTheme]
        itemAppearance.normal.iconColor = UIColor.secondaryLabel
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
