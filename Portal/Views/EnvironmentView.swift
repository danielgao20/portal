//
//  EnvironmentView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import SwiftUI
import CoreLocation
import AVKit

struct EnvironmentView: View {
    let environment: EnvironmentModel
    @StateObject private var audioService = AudioService()
    @State private var soundVolumes: [String: Float] = [:]
    @State private var isPlaying = false
    
    private func initializeVolumes() {
        // Default to 0.5 for each sound if not already set
        for sound in environment.sounds {
            if soundVolumes[sound] == nil {
                soundVolumes[sound] = 0.5
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 32) {
                VisualSoundscapeView(videoName: environment.imageName + "_visual")
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                Text(environment.name)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                VStack(spacing: 16) {
                    ForEach(environment.sounds, id: \.self) { sound in
                        HStack {
                            Text(sound.capitalized)
                                .foregroundColor(.white)
                            Slider(value: Binding(get: {
                                soundVolumes[sound, default: 0.5]
                            }, set: { newVal in
                                soundVolumes[sound] = newVal
                                audioService.setVolume(sound: sound, volume: newVal)
                            }), in: 0...1)
                        }
                    }
                }
                HStack(spacing: 24) {
                    Button(isPlaying ? "Stop" : "Play") {
                        if isPlaying {
                            audioService.stopAll()
                        } else {
                            for sound in environment.sounds {
                                audioService.play(sound: sound)
                                audioService.setVolume(sound: sound, volume: soundVolumes[sound, default: 0.5])
                            }
                        }
                        isPlaying.toggle()
                    }
                    .padding()
                    .background(isPlaying ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
                // Journaling prompt bar (appears at the bottom after entering environment)
                if let loc = CLLocationManager().location?.coordinate {
                    JournalingPromptBar(environment: .constant(environment.name), location: .constant(loc))
                }
            }
            .padding()
            .onAppear {
                initializeVolumes()
            }
        }
    }
}

