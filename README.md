# Whisper

一款专注于白噪音与自然声音的 iOS 应用，帮助你放松、专注或入睡。

## 功能特性

- **丰富的声音库**：河流、海浪、篝火、雨声、森林等，涵盖自然、动物、城市、雨天、场所、交通、物品等多个分类
- **分类浏览与搜索**：左右滑动切换分类，支持按名称快速搜索声音
- **自定义混合**：选取多种声音自由混合，创建专属氛围并保存
- **睡眠定时**：设置定时关闭，播放到指定时间后自动停止
- **主题与语言**：多主题颜色切换，支持中文 / 英文
- **优雅界面**：基于 SwiftUI，支持深色模式

## 预览


![声音页面](https://i.imgur.com/8N0Nnn2.jpeg)
![混合页面](https://i.imgur.com/pbXOs3v.jpeg)
![设置页面](https://i.imgur.com/Tb8zepH.jpeg)


## 技术栈

- **框架**：SwiftUI
- **平台**：iOS
- **依赖**：系统框架（AVFoundation、StoreKit 等），无第三方库

## 项目结构

```
Whisper/
├── MainTabView.swift       # 主 Tab 容器
├── WhisperApp.swift
├── Views/                  # 视图
│   ├── SoundView.swift     # 声音列表与分类
│   ├── MixSoundView.swift  # 自定义混合
│   ├── SettingView.swift   # 设置
│   ├── SleepTimerView.swift# 睡眠定时
│   ├── PlayingBarView.swift# 底部播放条
│   └── ...
├── ViewModels/             # 视图模型
├── Managers/               # 音频、声音等管理器
├── Model/                  # 数据模型
├── Store/                  # 配置与存储
└── sound.json              # 声音资源配置
```

## 环境要求

- Xcode 15+
- iOS 17+
- Swift 5.9+

## 运行方式

1. 克隆本仓库
2. 使用 Xcode 打开 `Whisper.xcodeproj`
3. 选择目标设备或模拟器，运行项目

## 许可证

本项目采用 [MIT License](LICENSE) 开源。

## 致谢

- 声音资源由 [rainsound.online](https://rainsound.online) CDN 提供

---

© Whisper · Built with SwiftUI
