//
//  CLGeocoder+ reverseGeocodeLocationPublisher.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import MapKit
import Combine

extension CLGeocoder {
    func reverseGeocodeLocationPublisher(_ location: CLLocation) -> AnyPublisher<CLPlacemark, Error> {
        Future<CLPlacemark, Error> { promise in
            self.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first else {
                    return promise(.failure(error ?? CLError(.geocodeFoundNoResult)))
                }
                return promise(.success(placemark))
            }
        }.eraseToAnyPublisher()
    }
}
