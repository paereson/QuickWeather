//
//  CityRealmModel.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 07/01/2023.
//

import Foundation
import RealmSwift

class CityRealmModel: Object {
    @Persisted var uuid: UUID = UUID()
    @Persisted var name: String
    @Persisted var formatted_address: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    func createFromResults(with result: Results) {
        self.name = result.name
        self.formatted_address = result.formatted_address
        self.latitude = result.geometry.location.lat
        self.longitude = result.geometry.location.lng
    }
    
    func getResults() -> Results {
        return Results(name: self.name, formatted_address: self.formatted_address, geometry: Geometry(location: Location(lat: latitude, lng: longitude)))
    }
}
