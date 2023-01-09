//
//  CitiesModel.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 07/01/2023.
//

import Foundation
import RealmSwift

// MARK: - CitiesModel
struct CitiesModel: Codable {
    var results: [Results]
}

struct Results: Codable {
    var name, formatted_address: String
    var geometry: Geometry
}

struct Geometry: Codable, Equatable {
    static func == (lhs: Geometry, rhs: Geometry) -> Bool {
        return lhs.location.lat == rhs.location.lat && lhs.location.lng == rhs.location.lng
    }
    
    var location: Location
}

struct Location: Codable {
    var lat, lng: Double
}
