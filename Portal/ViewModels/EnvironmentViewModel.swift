//
//  EnvironmentViewModel.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import Foundation
import Combine
import CoreLocation

class EnvironmentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var environments: [EnvironmentModel] = [
        EnvironmentModel(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Rainforest", imageName: "rainforest", sounds: ["rain", "birds"]),
        EnvironmentModel(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Beach", imageName: "beach", sounds: ["waves", "seagulls"]),
        EnvironmentModel(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Fireplace", imageName: "fireplace", sounds: ["fire", "wind"])
    ]
    
    @Published var suggestedEnvironment: EnvironmentModel? = nil
    @Published var currentWeather: String? = nil
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    
    private var locationManager: CLLocationManager?
    private var weatherService = WeatherService()
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        // Observe weather changes
        weatherService.$currentWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.currentWeather = weather
                self?.suggestedEnvironment = self?.environmentForWeather(weather)
            }
            .store(in: &cancellables)
    }
    
    func syncWeather() {
        requestLocation()
        weatherService.requestWeather()
    }
    
    func requestLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = loc.coordinate
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fallback to LA if location fails
        DispatchQueue.main.async {
            self.currentLocation = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        }
    }
    
    private func environmentForWeather(_ weather: String?) -> EnvironmentModel? {
        guard let weather = weather else { return nil }
        // Map OpenWeatherMap 'main' field to environment
        switch weather.lowercased() {
        case "rain", "drizzle", "thunderstorm":
            return environments.first(where: { $0.name == "Rainforest" })
        case "clear":
            return environments.first(where: { $0.name == "Beach" })
        case "snow":
            return environments.first(where: { $0.name == "Fireplace" })
        case "clouds":
            // Prefer Beach, fallback to Rainforest
            return environments.first(where: { $0.name == "Beach" }) ?? environments.first(where: { $0.name == "Rainforest" })
        default:
            return nil
        }
    }
}
