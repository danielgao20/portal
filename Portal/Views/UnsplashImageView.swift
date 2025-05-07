//  UnsplashImageView.swift
//  Portal
//
//  Created by Daniel Gao on 5/7/25.

import SwiftUI

struct UnsplashImageView: View {
    let query: String
    @StateObject private var unsplashService = UnsplashService()
    
    var body: some View {
        Group {
            if let url = unsplashService.imageUrl {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            unsplashService.fetchImage(for: query)
        }
    }
}
