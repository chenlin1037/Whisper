import Foundation
import CryptoKit

/// 声音模型（纯内存，不从 SwiftData 持久化）
final class Sound: Identifiable {

    /// 运行期唯一，用于 SwiftUI diff
    let id: UUID = UUID()

    /// 稳定唯一 ID（由 name + icon + url 决定）
    let stableID: String

    var name: String
    var icon: String
    var url: String
    var volume: Double
    var category: String
    var isPlaying: Bool = false

    init(
        name: String,
        icon: String,
        url: String,
        volume: Double = 0.5,
        category: String = "其他"
    ) {
        self.name = name
        self.icon = icon
        self.url = url
        self.volume = volume
        self.category = category

        self.stableID = Sound.makeStableID(
            name: name,
            icon: icon,
            url: url
        )
    }
}


extension Sound {

    static func makeStableID(
        name: String,
        icon: String,
        url: String
    ) -> String {
        let input = name + icon + url
        let data = Data(input.utf8)
        let digest = Insecure.MD5.hash(data: data)

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
