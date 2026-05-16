import Foundation
import SwiftData

@Model
final class CollectedSound {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var soundID: String
    var createdAt: Date

    init(id: UUID = UUID(), soundID: String, createdAt: Date = Date()) {
        self.id = id
        self.soundID = soundID
        self.createdAt = createdAt
    }
}
