//
//  JSONDecodingTest.swift
//  QuickWeatherTests
//
//  Created by Michał Gruszkiewicz on 09/01/2023.
//

import XCTest
@testable import QuickWeather

final class JSONDecodingTest: XCTestCase {
    enum TestError: Error {
        case fileNotFound
        case cantParseJSON
    }
    
    func getData(fromJSON fileName: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("Missing File: \(fileName).json")
            throw TestError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw error
        }
    }
    
    func testDecodingJSONWeather() throws {
        guard let data = try? getData(fromJSON: "weather"),
              let model = try? JSONDecoder().decode(WeatherModel.self, from: data) else {
            throw TestError.cantParseJSON
        }
        
        XCTAssertNotNil(model)
        XCTAssertEqual(model.city.name, "Szczepanowice")
        XCTAssertEqual(model.list.first?.main.temp, 4.72)
    }
}
