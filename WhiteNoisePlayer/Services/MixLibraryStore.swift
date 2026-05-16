//
//  MixLibraryStore.swift
//  WhiteNoisePlayer
//

import Foundation
import SwiftData

@MainActor
final class MixLibraryStore: ObservableObject {
    @Published private(set) var mixsounds: [Mixsound] = []
    @Published private(set) var error: Error?
    @Published var errorMessage: String?

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        load()
    }

    // MARK: - Public API

    func add(name: String, items: [MixsoundItem]) {
        let newMixsound = Mixsound(name: name, items: [])
        context.insert(newMixsound)

        for item in items {
            context.insert(item)
            item.mixsound = newMixsound
        }

        do {
            try context.save()

            error = nil
            load()
            print("DEBUG save success, mixsounds count: \(mixsounds.count)")
        } catch {
            self.error = error
            errorMessage = "保存失败：\(error.localizedDescription)"
            context.rollback()
            print("DEBUG save FAILED: \(error)")
            print("DEBUG save FAILED detail: \(error.localizedDescription)")
        }
    }

    func rename(id: UUID, new_name: String) {
        let trimmedName = new_name.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. 新增：检查去除空格后是否为空
        guard !trimmedName.isEmpty else {
            errorMessage = "名称不能为空"
            return
        }

        guard let mixsound = mixsounds.first(where: { $0.id == id }) else { return }
        let oldName = mixsound.name
        mixsound.name = trimmedName
        mixsound.markUpdated()
        do {
            try context.save()
            error = nil
        } catch {
            self.error = error
            mixsound.name = oldName
        }
    }

    func delete(id: UUID) {
        guard let mixsound = mixsounds.first(where: { $0.id == id }) else { return }
        context.delete(mixsound)
        do {
            try context.save()
            error = nil
            load()
        } catch {
            self.error = error
            context.rollback()
        }
    }

    // MARK: - Private

    private func load() {
        var descriptor = FetchDescriptor<Mixsound>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        // 只预取列表展示所需的字段，items 延迟加载
        // 播放时才会触发 items 的 fault，不会全部装入内存
        descriptor.propertiesToFetch = [\.id, \.name, \.createdAt, \.updatedAt]
        descriptor.fetchLimit = 200 // ← 防止数据量极大时全量加载

        do {
            mixsounds = try context.fetch(descriptor)
            error = nil
        } catch {
            self.error = error
            mixsounds = []
        }
    }
}
