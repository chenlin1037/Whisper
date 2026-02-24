//
//  AppConfig.swift
//  Whisper
//
//  Created by luckly on 2026/2/23.
//  App Store 上架配置：隐私政策、用户协议等 URL（上架前请替换为实际链接）
//

import Foundation

// MARK: - App Launch & Review

enum AppLaunchHandler {
    private static let launchCountKey = "app_launch_count"
    private static let hasReviewedKey = "has_reviewed"
    private static let minLaunchesBeforeReview = 3

    static func handleLaunch(requestReview: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: launchCountKey) + 1
        defaults.set(count, forKey: launchCountKey)

        let alreadyReviewed = defaults.bool(forKey: hasReviewedKey)
        if count >= minLaunchesBeforeReview && !alreadyReviewed {
            requestReview()
        }
    }
}

// MARK: - App Config

enum AppConfig {
    /// 隐私政策 URL（必填，App Store 审核要求）
    static let privacyPolicyURL = URL(string: "https://example.com/privacy")!

    /// 用户协议 URL
    static let termsOfServiceURL = URL(string: "https://example.com/terms")!

    /// 支持/反馈 URL
    static let supportURL = URL(string: "https://example.com/support")!

    /// App 显示名称
    static let appDisplayName = "Whisper"

    /// 版权信息
    static let copyright = "© \(Calendar.current.component(.year, from: Date())) \(appDisplayName)"

    /// App 版本
    static var appVersion: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }

    /// 构建号
    static var buildNumber: String {
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }
}
