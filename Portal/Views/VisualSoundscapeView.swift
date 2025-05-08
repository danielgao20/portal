//  VisualSoundscapeView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.

import SwiftUI
import AVKit

// visual soundscape video player
// wraps avplayercontroller for swiftui
struct VisualSoundscapeView: UIViewControllerRepresentable {
    let videoName: String // e.g. "rainforest_visual"
    let videoExtension: String = "mp4"
    
    // create avplayercontroller and loop video
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
    
    // no-op for now (could update video if environment changes)
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}
