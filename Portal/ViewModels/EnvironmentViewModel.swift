//
//  EnvironmentViewModel.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.
//

import Foundation
import Combine

class EnvironmentViewModel: ObservableObject {
    @Published var environments: [EnvironmentModel] = [
        EnvironmentModel(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Rainforest", imageName: "rainforest", sounds: ["rain", "birds"]),
        EnvironmentModel(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Beach", imageName: "beach", sounds: ["waves", "seagulls"]),
        EnvironmentModel(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Fireplace", imageName: "fireplace", sounds: ["fire", "wind"])
    ]
    
    @Published var suggestedEnvironment: EnvironmentModel? = nil
    @Published var currentWeather: String? = nil
    
    private var weatherService = WeatherService()
    
    init() {
        // Observe weather changes
        weatherService.$currentWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.currentWeather = weather
                self?.suggestedEnvironment = self?.environmentForWeather(weather)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    func syncWeather() {
        weatherService.requestWeather()
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
