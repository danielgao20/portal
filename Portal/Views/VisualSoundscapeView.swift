//  VisualSoundscapeView.swift
//  Portal
//
//  Created by Cascade AI

import SwiftUI
import AVKit

struct VisualSoundscapeView: UIViewControllerRepresentable {
    let videoName: String // e.g. "rainforest_visual"
    let videoExtension: String = "mp4"
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        if let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) {
            let player = AVPlayer(url: url)
            player.actionAtItemEnd = .none
            controller.player = player
            controller.showsPlaybackControls = false
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
            player.play()
        }
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // No-op for now (could update video if environment changes)
    }
}
