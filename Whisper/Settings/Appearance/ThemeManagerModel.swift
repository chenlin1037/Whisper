//
//  AppTheme.swift
//  Doone
//
//  Created by luckly on 2026/1/15.
//




import SwiftUI
import Combine

// MARK: - Theme Types
enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var displayName: String {
        switch self {
        case .system:
            return String(localized: "theme_system")
        case .light:
            return String(localized: "theme_light")
        case .dark:
            return String(localized: "theme_dark")
        }    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"
    
    private init() {
        // 从 UserDefaults 加载保存的主题，默认为跟随系统
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
    
    // MARK: - Public Methods
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    func getThemeDisplayName() -> String {
        return currentTheme.displayName
    }
    
    func getAllThemes() -> [AppTheme] {
        return AppTheme.allCases
    }
    
    // MARK: - Private Methods
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
}

// MARK: - Environment Key for Theme Manager
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Modifier for Theme Application
struct ThemeModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
    }
}

extension View {
    func applyTheme() -> some View {
        modifier(ThemeModifier())
    }
}
