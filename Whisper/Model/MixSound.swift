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
    var isPinned: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, items, createdAt, updatedAt, isPinned
    }

    init(
        id: UUID = UUID(),
        name: String,
        items: [MixSoundItem],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        items = try c.decode([MixSoundItem].self, forKey: .items)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }

    mutating func touch() {
        updatedAt = Date()
    }
}
