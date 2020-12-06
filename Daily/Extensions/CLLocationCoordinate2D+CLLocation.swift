//
//  CLLocationCoordinate2D+CLLocation.swift
//  Daily
//
//  Created by Diogo Silva on 12/05/20.
//

import MapKit

extension CLLocationCoordinate2D {
    func location() -> CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
