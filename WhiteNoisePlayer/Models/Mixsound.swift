import Foundation
import SwiftData

@Model
final class Mixsound {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \MixsoundItem.mixsound)
    var items: [MixsoundItem]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        items: [MixsoundItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 每次修改属性时自动更新 updatedAt
    func markUpdated() {
        self.updatedAt = Date()
    }
}

@Model
final class MixsoundItem {
    @Attribute(.unique) var id:UUID
    var soundID: String
    var volume: Float
    var mixsound: Mixsound?

    init(soundID: String, volume: Float) {
        self.id = UUID()
        self.soundID = soundID
        self.volume = volume
    }
}