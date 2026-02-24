//
//  Theme.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//


import SwiftUI

extension Color {
    /// App global theme color: #8872d9ff
    static let appTheme = Color(red: 136 / 255, green: 114 / 255, blue: 217 / 255)
}

extension UIColor {
    static let appTheme = UIColor(Color.appTheme)
}

