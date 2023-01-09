//
//  WeatherModel.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import Foundation

struct WeatherModel: Codable {
    var list: [List]
    var city: City
}

struct List: Codable, Identifiable {
    var id: UUID { UUID() }
    var dt: Int
    var main: Main
    var weather: [Weather]
    var wind: Wind
    let pop: Double
    
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
}

struct Main: Codable {
    var temp, temp_min, temp_max: Double
}

struct Weather: Codable {
    var id: Int
    var main, description: String
    
    var getImage: String {
        switch id {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}

struct Wind: Codable {
    var speed: Double
}

struct City: Codable {
    var name, country: String
}
