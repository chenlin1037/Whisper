//
//  Theme.swift
//  Whisper
//
//  Created by luckly on 2026/1/24.
//


import SwiftUI

extension Color {
    /// App global theme color: #8872d9ff
    static let appTheme = Color(red: 53 / 255, green: 94 / 255, blue: 202 / 255)
}

extension UIColor {
    static let appTheme = UIColor(Color.appTheme)
}

