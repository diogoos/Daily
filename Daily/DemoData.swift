//
//  DemoData.swift
//  Daily
//
//  Created by Diogo Silva on 11/13/20.
//

import Foundation
import MapKit

struct DemoData {
//    static var names: [String] = (0..<20).map({ _ in title() })
//
//    static func title() -> String {
//        let a = ["Fun", "Amazing", "Regular", "Interesting", "Awe insipring", "Profound", "Superb"]
//        let b = ["Day", "Experience", "Trip", "Adventure"]
//        let d = ["Friends", "Family", "Coworkers", "Pet"]
//
//        let title = a.randomElement()! + " " + b.randomElement()! + " with " + d.randomElement()!
//        return title
//    }
//
//    static var temps: [Int] = {
//        Array<Optional<Bool>>(repeating: nil, count: names.count).map { _ in
//            Int.random(in: 18...32)
//        }
//    }()
//
//    static func entries() -> [Entry] {
//        var entries = [Entry]()
//        for idx in 0..<names.count {
//            entries.append(Entry(date: Date(),
//                                 title: names[idx],
//                                 content: "Today was a very " + names[idx].lowercased(),
//                                 metadata: Entry.Metadata(location: randomUSCoordinate(),
//                                                          temperature: Double(temps[idx]))))
//        }
//        return entries
//    }
//
//    static func randomUSCoordinate() -> CLLocationCoordinate2D {
//        let latitude: CLLocationDegrees = Double.random(in: 24.9493...49.5904)
//        let longitude: CLLocationDegrees = Double.random(in: -125.0011...(-66.9326))
//        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//
//
    static func demoAddressForLocation(_ location: CLLocationCoordinate2D, callback: @escaping (String)->()) {
        let coder = CLGeocoder()
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        coder.reverseGeocodeLocation(location, completionHandler: { placemarks, err in
            let city = placemarks?.first?.locality ?? "Bogustown"
            callback(city)
        })
    }
}
