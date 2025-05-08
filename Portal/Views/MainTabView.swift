//
//  MainTabView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        // main tab layout
        TabView {
            // home tab
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            // favorites tab
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }

            // spotify tab
            SpotifyTrackView()
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Spotify")
                }
        }
    }
}
