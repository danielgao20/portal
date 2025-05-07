//
//  SettingsView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var weatherSync = false
    @State private var spotifySync = false
    @State private var darkMode = false
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Weather Sync", isOn: $weatherSync)
                Toggle("Spotify Sync", isOn: $spotifySync)
                Toggle("Dark Mode", isOn: $darkMode)
            }
            .navigationTitle("Settings")
        }
    }
}
