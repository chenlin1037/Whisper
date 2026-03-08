//
//  SoundLoader.swift
//  Whisper
//
//  声音加载服务：从 JSON 解析声音列表
//

import Foundation

enum SoundLoader {
    private struct LocalSoundDTO: Decodable {
        let name: String
        let url: String
        let category: String?
        let icon: String?
    }

    /// 从 Bundle 的 sound.json 加载声音列表
    static func loadFromBundle() async throws -> [Sound] {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let fileURL = Bundle.main.url(forResource: "sound", withExtension: "json") else {
                    continuation.resume(throwing: NSError(
                        domain: "SoundLoader",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "未找到 sound.json 文件"]
                    ))
                    return
                }

                do {
                    let data = try Data(contentsOf: fileURL)
                    let items = try JSONDecoder().decode([LocalSoundDTO].self, from: data)
                    let sounds = items.map { item -> Sound in
                        let iconName: String
                        if let icon = item.icon?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !icon.isEmpty {
                            iconName = (icon as NSString).deletingPathExtension
                        } else {
                            iconName = "play"
                        }
                        let category: String
                        if let cat = item.category?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !cat.isEmpty {
                            category = cat
                        } else {
                            category = "未分类"
                        }
                        return Sound(
                            name: item.name,
                            icon: iconName,
                            url: item.url,
                            volume: 0.5,
                            category: category
                        )
                    }
                    continuation.resume(returning: sounds)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
