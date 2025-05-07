//
//  ContentView.swift
//  Portal
//
//  Created by Daniel Gao on 5/5/25.
//

import SwiftUI
import CoreLocation
import Combine

struct ContentView: View {
    @StateObject var viewModel = EnvironmentViewModel()
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var selectedIndex = -1
    @State private var showTimer = false
    @State private var showSuggestedEnv = false
    @State private var mapCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedIndex) {
                    // First slide: Weather sync & suggestion with map
                    VStack(spacing: 24) {
                        Button("Sync Weather") {
                            viewModel.syncWeather()
                            // Try to get user location, else fallback to default
                            if let loc = viewModel.currentLocation {
                                mapCoordinate = loc
                            } else {
                                mapCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
                            }
                        }
                        .font(.title2)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)

                        if let suggested = viewModel.suggestedEnvironment {
                            HStack {
                                Image(systemName: "cloud.sun.rain")
                                    .foregroundColor(.blue)
                                Text("Suggested: \(suggested.name) based on weather")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(10)
                        }

                        Text("Your Location")
                            .font(.headline)
                            .padding(.top)
                        MapKitView(coordinate: mapCoordinate)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 8)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding(.top, 32)
                    .tag(-1)

                    // Remaining slides: Environments
                    ForEach(viewModel.environments.indices, id: \ .self) { index in
                        let env = viewModel.environments[index]
                        VStack {
                            UnsplashImageView(query: env.name)
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(radius: 12)
                                .padding(.vertical)

                            Text(env.name)
                                .font(.title)
                                .padding(.top)

                            NavigationLink("Enter", destination: EnvironmentView(environment: env))
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                            Button(action: {
                                if favoritesVM.favorites.contains(where: { $0.id == env.id }) {
                                    favoritesVM.removeFavorite(env)
                                } else {
                                    favoritesVM.addFavorite(env: env)
                                }
                            }) {
                                Image(systemName: favoritesVM.favorites.contains(where: { $0.id == env.id }) ? "heart.fill" : "heart")
                                    .foregroundColor(.pink)
                            }
                            .padding(.top, 8)
                            Button("Timer") {
                                showTimer = true
                            }
                            .padding(.top, 8)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(height: 500)
            }
            .navigationTitle("Portal")
            .sheet(isPresented: $showTimer) {
                TimerModalView(isPresented: $showTimer)
            }
        }
    }
}

#Preview {
    ContentView()
}
