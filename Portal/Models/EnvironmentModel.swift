//  EnvironmentModel.swift
//  Portal
//
//  Created by Daniel Gao on 5/7/25.

import Foundation

struct EnvironmentModel: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let imageName: String
    let sounds: [String]

    init(id: UUID = UUID(), name: String, imageName: String, sounds: [String]) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.sounds = sounds
    }
}