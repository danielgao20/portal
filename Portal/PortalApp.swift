//
//  PortalApp.swift
//  Portal
//
//  Created by Daniel Gao on 5/5/25.
//

import SwiftUI

@main
struct PortalApp: App {
    @StateObject var favoritesVM = FavoritesViewModel()
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesVM)
        }
    }
}
