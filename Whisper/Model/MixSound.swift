//
//  MixSoundItem.swift
//  Whisper
//
//  Created by luckly on 2026/2/10.
//


import Foundation

// MARK: - MixSoundItem

/// 混合中的单个声音（使用 stableID）
struct MixSoundItem: Codable, Hashable {
    let soundStableID: String
    var volume: Double
}

// MARK: - MixSound

struct MixSound: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: [MixSoundItem]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [MixSoundItem],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    mutating func touch() {
        updatedAt = Date()
    }
}
