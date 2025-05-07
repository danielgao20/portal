//  FavoritesViewModel.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.

import Foundation

import SwiftUI
import Foundation

class FavoritesViewModel: ObservableObject {
    @AppStorage("favoritedEnvironments") private var favoritedEnvironmentsData: Data = Data()
    @Published var favorites: [EnvironmentModel] = []

    init() {
        loadFavorites()
    }

    private func loadFavorites() {
        guard !favoritedEnvironmentsData.isEmpty else {
            favorites = []
            return
        }
        if let decoded = try? JSONDecoder().decode([EnvironmentModel].self, from: favoritedEnvironmentsData) {
            favorites = decoded
        } else {
            favorites = []
        }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            favoritedEnvironmentsData = encoded
        }
    }

    func addFavorite(env: EnvironmentModel) {
        if !favorites.contains(where: { $0.id == env.id }) {
            favorites.append(env)
            saveFavorites()
        }
    }

    func removeFavorite(_ env: EnvironmentModel) {
        if let index = favorites.firstIndex(where: { $0.id == env.id }) {
            favorites.remove(at: index)
            saveFavorites()
        }
    }
}

