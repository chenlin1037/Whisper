import Foundation
import SwiftData

@MainActor
final class CollectionStore: ObservableObject {

    @Published private(set) var collectedSounds: [CollectedSound] = []
    @Published private(set) var error: Error?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        load()
    }

    // MARK: - Public API

    var collectedSoundIDs: [String] {
        collectedSounds.map(\.soundID)
    }

    func contains(soundID: String) -> Bool {
        collectedSounds.contains { $0.soundID == soundID }
    }

    func toggle(soundID: String) {
        contains(soundID: soundID) ? remove(soundID: soundID) : add(soundID: soundID)
    }

    func add(soundID: String) {
        guard !contains(soundID: soundID) else { return }
        let obj = CollectedSound(soundID: soundID)
        context.insert(obj)
        do {
            try context.save()
            collectedSounds.insert(obj, at: 0)
            error = nil
        } catch {
            self.error = error
            context.rollback()
        }
    }

    func remove(soundID: String) {
        guard let obj = collectedSounds.first(where: { $0.soundID == soundID }) else { return }
        context.delete(obj)
        do {
            try context.save()
            collectedSounds.removeAll { $0.soundID == soundID }
            error = nil
        } catch {
            self.error = error
            context.rollback()
        }
    }

    // MARK: - Private

    private func load() {
        let descriptor = FetchDescriptor<CollectedSound>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            collectedSounds = try context.fetch(descriptor)
            error = nil
        } catch {
            self.error = error
            collectedSounds = []
        }
    }
}
