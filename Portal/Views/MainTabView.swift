//
//  MainTabView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
                }

            SpotifyTrackView()
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Spotify")
                }
        }
    }
}
