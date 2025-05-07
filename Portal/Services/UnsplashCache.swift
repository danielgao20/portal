//  UnsplashCache.swift
//  Portal
//
//  Created by Daniel Gao on 5/7/25.

import Foundation

class UnsplashCache: ObservableObject {
    static let shared = UnsplashCache()
    @Published var imageUrls: [String: URL] = [:] // query: url
    
    func url(for query: String) -> URL? {
        imageUrls[query]
    }
    
    func set(url: URL, for query: String) {
        imageUrls[query] = url
    }
    
    func clear() {
        imageUrls.removeAll()
    }
}
