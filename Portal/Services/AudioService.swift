//  AudioService.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.

import Foundation
import AVFoundation

class AudioService: ObservableObject {
    @Published var players: [String: AVAudioPlayer] = [:]
    
    init() {
        // Set up audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession: \(error)")
        }
        // Observe interruptions
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            // Pause all audio
            for player in players.values {
                player.pause()
            }
        } else if type == .ended {
            // Optionally resume playback
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    for player in players.values {
                        player.play()
                    }
                }
            }
        }
    }
    
    func play(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.play()
            players[sound] = player
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func stop(sound: String) {
        players[sound]?.stop()
        players.removeValue(forKey: sound)
    }
    
    func setVolume(sound: String, volume: Float) {
        players[sound]?.volume = volume
    }
    
    func stopAll() {
        for player in players.values {
            player.stop()
        }
        players.removeAll()
    }
}
