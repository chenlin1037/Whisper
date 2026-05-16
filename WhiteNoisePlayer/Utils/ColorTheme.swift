//
//  ColorTheme.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

import SwiftUI

extension Color {
    // MARK: - 品牌色 (保持不变)
    static let selectedColor = Color(red: 40 / 255, green: 103 / 255, blue: 120 / 255)
    static let accent = Color(red: 111 / 255, green: 156 / 255, blue: 170 / 255)

    // MARK: - 动态背景色 (使用 UIColor 闭包实现适配)
    
    /// 主背景色
    static let surface = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 12 / 255, green: 14 / 255, blue: 18 / 255, alpha: 1.0)
        default:
            return UIColor(red: 246 / 255, green: 244 / 255, blue: 238 / 255, alpha: 1.0)
        }
    })

    /// 雾气效果
    static let mist = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 28 / 255, green: 32 / 255, blue: 38 / 255, alpha: 1.0)
        default:
            return UIColor(red: 226 / 255, green: 236 / 255, blue: 235 / 255, alpha: 1.0)
        }
    })

    /// 暖光
    static let warmGlow = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 60 / 255, green: 50 / 255, blue: 40 / 255, alpha: 1.0)
        default:
            return UIColor(red: 245 / 255, green: 224 / 255, blue: 195 / 255, alpha: 1.0)
        }
    })

    // MARK: - 动态组件色

    /// 面板/弹窗背景
    static let panel = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            // 深色模式下使用半透明的深灰色
            return UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 0.85)
        default:
            // 浅色模式保持原样
            return UIColor.white.withAlphaComponent(0.78)
        }
    })

    /// 卡片基础色
    static let cardBase = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            // 深色模式下比背景稍亮，体现层级
            return UIColor(red: 0.18, green: 0.18, blue: 0.22, alpha: 1.0)
        default:
            return UIColor.white.withAlphaComponent(0.72)
        }
    })

    // MARK: - 动态文字色 (关键修复)

    /// 墨水色：自动在深色背景下变白
    static let ink = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1.0)
        default:
            return UIColor(red: 45 / 255, green: 59 / 255, blue: 67 / 255, alpha: 1.0)
        }
    })
}

extension LinearGradient {
    static let appBackground = LinearGradient(
        colors: [
            Color.surface,
            Color.mist.opacity(0.95),
            Color.warmGlow.opacity(0.55)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension RadialGradient {
    static let heroGlow = RadialGradient(
        colors: [
            Color.white.opacity(0.95),
            Color.mist.opacity(0.5),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 20,
        endRadius: 260
    )
}