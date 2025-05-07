//
//  ContentView.swift
//  Portal
//
//  Created by Daniel Gao on 5/5/25.
//

import SwiftUI

import Combine

struct ContentView: View {
    @StateObject var viewModel = EnvironmentViewModel()
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var selectedIndex = 0
    @State private var showTimer = false
    @State private var showSuggestedEnv = false

    var body: some View {
        NavigationStack {
            VStack {
                // Weather suggestion banner
                if let suggested = viewModel.suggestedEnvironment {
                    Button(action: { showSuggestedEnv = true }) {
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
                    .sheet(isPresented: $showSuggestedEnv) {
                        EnvironmentView(environment: suggested)
                    }
                }
                Button("Sync Weather") {
                    viewModel.syncWeather()
                }
                .padding(.bottom, 8)

                TabView(selection: $selectedIndex) {
                    ForEach(viewModel.environments.indices, id: \.self) { index in
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
