//  UnsplashService.swift
//  Portal
//
//  Created by Daniel Gao on 5/7/25.

import Foundation
import SwiftUI

class UnsplashService: ObservableObject {
    private let accessKey = "l4c2xzUVhD0puwi2cGIQf-_rwtCgCtuSk1Z70o4Uw1s"
    
    @Published var imageUrl: URL? = nil
    private var currentTask: URLSessionDataTask?
    
    func fetchImage(for query: String) {
        currentTask?.cancel()
        let queryEscaped = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.unsplash.com/photos/random?query=\(queryEscaped)&orientation=landscape&client_id=\(accessKey)"
        guard let url = URL(string: urlString) else { return }
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let urls = json["urls"] as? [String: Any],
               let raw = urls["regular"] as? String,
               let imageUrl = URL(string: raw) {
                DispatchQueue.main.async {
                    self.imageUrl = imageUrl
                }
            }
        }
        currentTask?.resume()
    }
}
