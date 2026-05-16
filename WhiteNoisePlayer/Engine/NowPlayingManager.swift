//
//  NowPlayingManager.swift
//  WhiteNoisePlayer
//

import AVFoundation
import Foundation
import MediaPlayer
import UIKit

final class NowPlayingManager {
    static let shared = NowPlayingManager()

    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()

    private init() {}

    func setupRemoteCommands(
        playHandler: @escaping () -> Void,
        pauseHandler: @escaping () -> Void,
        toggleHandler: @escaping () -> Void
    ) {
        // ✅ 用 removeTarget(nil) 移除所有已注册的 target
        remoteCommandCenter.playCommand.removeTarget(nil)
        remoteCommandCenter.pauseCommand.removeTarget(nil)
        remoteCommandCenter.togglePlayPauseCommand.removeTarget(nil)
        remoteCommandCenter.stopCommand.removeTarget(nil)
        remoteCommandCenter.nextTrackCommand.isEnabled = false
        remoteCommandCenter.previousTrackCommand.isEnabled = false
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = false
        remoteCommandCenter.stopCommand.isEnabled = false

        UIApplication.shared.beginReceivingRemoteControlEvents()

        // Play command
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.playCommand.addTarget { _ in
            playHandler()
            return .success
        }

        // Pause command
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget { _ in
            pauseHandler()
            return .success
        }

        remoteCommandCenter.togglePlayPauseCommand.isEnabled = true
        remoteCommandCenter.togglePlayPauseCommand.addTarget { _ in
            toggleHandler()
            return .success
        }

    }

    func updateNowPlaying(title: String, artist: String = "WhiteNoisePlayer", isPlaying: Bool, artworkName: String? = nil) {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = title
        info[MPMediaItemPropertyArtist] = artist
        info[MPNowPlayingInfoPropertyIsLiveStream] = true // 白噪音无固定时长
        info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        // AppIcon 通常不能通过 UIImage(named:) 稳定取到，优先使用声音自己的图片资源。
        if let image = artworkImage(named: artworkName) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfoCenter.nowPlayingInfo = info
        nowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused
    }

    func clearNowPlaying() {
        nowPlayingInfoCenter.nowPlayingInfo = nil
        nowPlayingInfoCenter.playbackState = .stopped
    }

    private func artworkImage(named name: String?) -> UIImage? {
        let icon = name.flatMap { UIImage(named: $0) }
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: format)

        return renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: 512, height: 512)
            drawArtworkBackground(in: rect, context: context.cgContext)

            if let icon {
                let image = icon.withTintColor(.white, renderingMode: .alwaysOriginal)
                image.draw(in: CGRect(x: 128, y: 128, width: 256, height: 256), blendMode: .normal, alpha: 0.96)
            } else {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 172, weight: .semibold),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraph
                ]
                NSString(string: "WN").draw(in: CGRect(x: 0, y: 156, width: 512, height: 220), withAttributes: attributes)
            }
        }
    }

    private func drawArtworkBackground(in rect: CGRect, context: CGContext) {
        let colors = [
            UIColor(red: 0.13, green: 0.20, blue: 0.23, alpha: 1).cgColor,
            UIColor(red: 0.22, green: 0.48, blue: 0.50, alpha: 1).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0, 1]
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.minX, y: rect.minY),
                end: CGPoint(x: rect.maxX, y: rect.maxY),
                options: []
            )
        }
    }
}
