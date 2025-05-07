//  WeatherService.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.

import Foundation
import CoreLocation
import MapKit

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let apiKey = "1a4001cd7b67e5ff289a1a970578416e"
    @Published var currentWeather: String? = nil
    private let manager = CLLocationManager()
    var mapView: MKMapView? = nil // For future MapKit expansion
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    /// Public method to simulate weather fetch with CoreLocation+MapKit setup, but always uses a hardcoded location.
    func requestWeather() {
        fetchWeather(lat: 34.0522, lon: -118.2437)
    }
    
    private func fetchWeather(lat: Double, lon: Double) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let weather = self.parseWeather(data: data) {
                    DispatchQueue.main.async {
                        self.currentWeather = weather
                    }
                }
            }
        }.resume()
    }
    
    private func parseWeather(data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let weatherArr = json["weather"] as? [[String: Any]],
           let main = weatherArr.first?["main"] as? String {
            return main
        }
        return nil
    }
}
