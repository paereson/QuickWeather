//
//  RESTService.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import Foundation
import CoreLocation
import Alamofire

class RESTService {
    static let apiToken = "509dc0f3dc1b993966b7673329097e2b"
    static let googlePlacesAPIToken = "AIzaSyDjoCIFn5uU2GDR_4d5QztnLGuc16Y3-kg"
    
    static func getWeatherForLocation(lat: CLLocationDegrees, lon: CLLocationDegrees, completion: @escaping (WeatherModel?) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiToken)&units=metric"
        
        let request = AF.request(url)
        request.responseDecodable(of: WeatherModel.self) { response in
            guard let weatherData = response.value else {
                completion(nil)
                return
            }
            completion(weatherData)
        }
    }
    
    static func getWeatherForCity(city: String, completion: @escaping (WeatherModel?) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiToken)&units=metric"
        
        let request = AF.request(url)
        request.responseDecodable(of: WeatherModel.self) { response in
            guard let weatherData = response.value else {
                completion(nil)
                return
            }
            completion(weatherData)
        }
    }
    
    static func getCitiesList(city: String, completion: @escaping (CitiesModel?) -> Void) {
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(city)&key=\(googlePlacesAPIToken)&types=locality"
        
        let request = AF.request(url)
        request.responseDecodable(of: CitiesModel.self) { response in
            guard let cities = response.value else {
                completion(nil)
                return
            }
            completion(cities)
        }
    }
}
