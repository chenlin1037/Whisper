//
//  Sound.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

import Foundation

// MARK: - 声音预设数据模型 (纯数据层)

struct Sound: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String
    let url: URL
    let category: Category

    enum Category: String, CaseIterable, Comparable, Codable {
        case nature    = "Nature"
        case rain      = "Rain"
        case animals   = "Animals"
        case urban     = "Urban"
        case places    = "Places"
        case transport = "Transport"
        case things    = "Things"

        static func < (lhs: Category, rhs: Category) -> Bool {
            return allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
        }
    }
}