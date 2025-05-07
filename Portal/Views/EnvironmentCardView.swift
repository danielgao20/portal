//  EnvironmentCardView.swift
//  Portal
//
//  Created by Daniel Gao on 5/7/25.

import SwiftUI

struct EnvironmentCardView: View {
    let environment: EnvironmentModel
    @StateObject private var unsplashService = UnsplashService()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = unsplashService.imageUrl {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
            } else {
                Color.gray.opacity(0.2)
            }
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text(environment.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

            }
            .padding()
        }
        .frame(height: 180)
        .cornerRadius(18)
        .shadow(radius: 6)
        .onAppear {
            unsplashService.fetchImage(for: environment.name)
        }
    }
}
