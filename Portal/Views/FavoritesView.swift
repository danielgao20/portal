//
//  FavoritesView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var viewModel: FavoritesViewModel
    @State private var showEnvironment: Bool = false
    @State private var selectedEnv: EnvironmentModel?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.favorites.isEmpty {
                    Text("No favorites yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.favorites) { fav in
    HStack {
        Image(fav.imageName)
            .resizable()
            .frame(width: 60, height: 60)
            .clipShape(Circle())
        Text(fav.name)
            .font(.headline)
        Spacer()
        Button("Enter") {
            selectedEnv = fav
            showEnvironment = true
        }
        .buttonStyle(.borderedProminent)
        Button(role: .destructive) {
            viewModel.removeFavorite(fav)
        } label: {
            Image(systemName: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .sheet(isPresented: $showEnvironment) {
                if let selectedEnv = selectedEnv {
                    EnvironmentView(environment: selectedEnv)
                }
            }
        }
    }
}

