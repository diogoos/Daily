//
//  WeatherAPI.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import MapKit
import Combine


class WeatherAPI {
    static let weatherApiKey = "f70a77f99ae3db69c4af8d0f6373134d"
    static let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&units=metric&appid=\(weatherApiKey)"

    static func weatherApiUrl(for location: CLLocationCoordinate2D) -> URL {
        let urlString = Self.weatherApiUrl.replacingOccurrences(of: "${lat}", with: String(format: "%f", location.latitude))
            .replacingOccurrences(of: "${lon}", with: String(format: "%f", location.latitude))
        guard let url = URL(string: urlString) else { fatalError("Invalid hard-coded weather API url.") }
        return url
    }

    struct WeatherResponse: Codable {
        var weather: [WeatherData]
        var main: TemperatureData

        struct TemperatureData: Codable { var temp: Double }
        struct WeatherData: Codable { var description: String }

        var localizedTemperature: String {
            let temperature = Measurement(value: main.temp, unit: UnitTemperature.celsius)
            return MeasurementFormatter().string(from: temperature)
        }
    }
}
