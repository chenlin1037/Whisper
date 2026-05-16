//
//  SoundDataManager.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/5/2.
//

import Foundation

class SoundDataManager {
    
    // 1. 单例模式：全局唯一实例
    static let shared = SoundDataManager()
    
    // 2. 私有初始化：防止外部通过 SoundDataManager() 创建新实例
    private init() {}
    
    // 3. 核心数据源：懒加载，第一次访问时才解析 JSON
    lazy var sounds: [Sound] = loadSoundsFromJSON()
    
    /// 从 Bundle 加载并解析 sounds.json
    private func loadSoundsFromJSON() -> [Sound] {
        guard let url = Bundle.main.url(forResource: "sounds", withExtension: "json") else {
            print("❌ 错误: 找不到 sounds.json 文件")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let loadedSounds = try decoder.decode([Sound].self, from: data)
            return loadedSounds
        } catch {
            print("❌ 错误: 解码 JSON 失败 - \(error)")
            return []
        }
    }
    
    // 4. 业务逻辑方法
    
    /// 获取按类别分组的声音元组
    func getSoundsGroupedByCategory() -> [(category: Sound.Category, sounds: [Sound])] {
        let validCategories = Sound.Category.allCases
        
        return validCategories.map { cat in
            let filteredSounds = sounds.filter { $0.category == cat }
            return (category: cat, sounds: filteredSounds)
        }.filter { !$0.sounds.isEmpty }
    }
    
    /// 获取所有分类名称列表
    func getAllCategories() -> [String] {
        var result = ["All"]
        result += Sound.Category.allCases.map { $0.rawValue }
        return result
    }
}