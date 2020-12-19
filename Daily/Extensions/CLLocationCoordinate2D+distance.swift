//
//  CLLocationCoordinate2D+distance.swift
//  Daily
//
//  Created by Diogo Silva on 12/19/20.
//

import MapKit

extension CLLocationCoordinate2D {
    func distance(to: Self) -> Double {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }
}
