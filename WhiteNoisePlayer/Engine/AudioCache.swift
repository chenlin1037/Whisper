//
//  AudioCache.swift
//  WhiteNoisePlayer
//

import Foundation
import CryptoKit

actor AudioCache {

    private let directory: URL

    /// 磁盘缓存上限，默认 500 MB
    private let maxDiskBytes: Int

    init(maxDiskBytes: Int = 500 * 1024 * 1024) {
        self.maxDiskBytes = maxDiskBytes
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("WhiteNoiseAudio", isDirectory: true)
    }

    // MARK: - Public API

    /// 查找本地缓存，命中时 touch 修改时间以维护 LRU 顺序
    func localURL(for remoteURL: URL) -> URL? {
        let dest = destinationURL(for: remoteURL)
        guard FileManager.default.fileExists(atPath: dest.path) else { return nil }
        touchModificationDate(dest)
        return dest
    }

    /// 目标文件路径（下载前调用，用于告知 NetworkLoader 写到哪里）
    func destinationURL(for remoteURL: URL) -> URL {
        let hash = SHA256.hash(data: Data(remoteURL.absoluteString.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        return directory.appendingPathComponent(hash + ".caf")
    }

    /// 确保缓存目录存在（在首次使用前调用，而非在 init 里做 I/O）
    func prepareDirectoryIfNeeded() throws {
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    /// 清理超出容量上限的文件（按 LRU 顺序），同时清理孤立的临时文件
    func evictIfNeeded() throws {
        let fm = FileManager.default
        let resourceKeys: Set<URLResourceKey> = [
            .fileSizeKey,
            .contentModificationDateKey,
            .nameKey
        ]

        let allFiles = try fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: .skipsHiddenFiles
        )

        // 清理孤立的临时文件（有 .download 但没有对应 .caf）
        let cafNames = Set(allFiles.filter { $0.pathExtension == "caf" }
            .map { $0.deletingPathExtension().lastPathComponent })

        for file in allFiles where file.pathExtension == "download" || file.pathExtension == "etag" {
            let baseName = file.deletingPathExtension().deletingPathExtension().lastPathComponent
            if !cafNames.contains(baseName) {
                try? fm.removeItem(at: file)
            }
        }

        // 按修改时间排序（最近访问的排前面）
        let cafFiles = allFiles
            .filter { $0.pathExtension == "caf" }
            .compactMap { url -> (url: URL, size: Int, date: Date)? in
                let values = try? url.resourceValues(forKeys: resourceKeys)
                guard let size = values?.fileSize,
                      let date = values?.contentModificationDate
                else { return nil }
                return (url, size, date)
            }
            .sorted { $0.date > $1.date }  // 最近的排前面

        // 累计超出上限的部分，从最旧的文件开始删除
        var totalBytes = cafFiles.reduce(0) { $0 + $1.size }
        for entry in cafFiles.reversed() {
            guard totalBytes > maxDiskBytes else { break }
            try? fm.removeItem(at: entry.url)
            // 同时清理对应的临时文件
            try? fm.removeItem(at: entry.url.appendingPathExtension("download"))
            try? fm.removeItem(at: entry.url.appendingPathExtension("etag"))
            totalBytes -= entry.size
        }
    }

    /// 清空全部缓存
    func clearAll() throws {
        try FileManager.default.removeItem(at: directory)
        try prepareDirectoryIfNeeded()
    }

    // MARK: - Private

    /// 更新文件修改时间，用于维护基于磁盘的 LRU 顺序
    private func touchModificationDate(_ url: URL) {
        try? FileManager.default.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: url.path
        )
    }
}