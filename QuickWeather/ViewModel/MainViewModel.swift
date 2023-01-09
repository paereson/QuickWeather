//
//  MainViewModel.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import Foundation
import CoreLocation
import Combine

class MainViewModel {
    
    var restService: RESTService
    @Published var weather: WeatherModel?
    
    // MARK: Init
    init(restService: RESTService = RESTService()) {
        self.restService = restService
        checkDefaultCity()
    }
    
    private func checkDefaultCity() {
        let historyCities = PersistenceManagerImp().fetchObjects(CityRealmModel.self) as? [CityRealmModel]
        if historyCities != [], let first = historyCities?.first {
            getNewWeatherData(lat: first.latitude, lon: first.longitude)
        } else {
            getNewWeatherDataForCity(city: "Warsaw")
        }
    }
    
    // MARK: Funcs
    func getNewWeatherData(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        RESTService.getWeatherForLocation(lat: lat, lon: lon) { [weak self] responseWeather in
            self?.weather = responseWeather
        }
    }
    
    func getNewWeatherDataForCity(city: String) {
        RESTService.getWeatherForCity(city: city) { [weak self] responseWeather in
            self?.weather = responseWeather
        }
    }
    
    // MARK: Test funcs
    func getTestWeatherData() {
        RESTService.getWeatherForLocation(lat: 51.1000, lon: 17.0333) { [weak self] responseWeather in
            self?.weather = responseWeather
        }
    }
}
