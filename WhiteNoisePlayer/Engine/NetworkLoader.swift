//
//  NetworkLoader.swift
//  WhiteNoisePlayer
//

import Foundation

actor NetworkLoader {
    /// 先查缓存，再下载到磁盘
    func fetch(url: URL, cache: AudioCache) async throws -> URL {
        try await cache.prepareDirectoryIfNeeded()
        if let cached = await cache.localURL(for: url) {
            return cached
        }
        let destination = await cache.destinationURL(for: url)
        try await download(from: url, to: destination)
        try await cache.evictIfNeeded()
        return destination
    }

    private func download(from url: URL, to destination: URL) async throws {
        // 用系统级下载，直接写磁盘，内存占用极低
        // 原来的逐字节 asyncBytes 循环会导致 1000 万次 async 调度，CPU/内存双爆
        let (tmpURL, response) = try await URLSession.shared.download(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            try? FileManager.default.removeItem(at: tmpURL)
            throw URLError(.badServerResponse)
        }

        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tmpURL, to: destination)
    }
}
