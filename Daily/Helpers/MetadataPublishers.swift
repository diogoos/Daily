//
//  MetadataPublishers.swift
//  Daily
//
//  Created by Diogo Silva on 12/06/20.
//

import Combine
import MapKit

class MetadataPublishers {
    var locationPublisher: AnyPublisher<CLLocation, Error>

    init(locationPublisher: AnyPublisher<CLLocation, Error>) {
        self.locationPublisher = locationPublisher
    }

    lazy var temperaturePublisher: AnyPublisher<WeatherAPI.WeatherResponse, Error> = {
        locationPublisher
            .map { WeatherAPI.weatherApiUrl(for: $0.coordinate) }
            .flatMap { URLSession.shared.dataTaskPublisher(for: $0)
                        .mapError { $0 as Error } }
            .map { $0.data }
            .decode(type: WeatherAPI.WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }()

    lazy var placemarkPublisher: AnyPublisher<String, Error> = {
        locationPublisher
            .flatMap { CLGeocoder().reverseGeocodeLocationPublisher($0) }
            .map(\.formattedString)
            .eraseToAnyPublisher()
    }()
}
