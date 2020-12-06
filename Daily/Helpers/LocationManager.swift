//
//  LocationManager.swift
//  Daily
//
//  Original by Felix M. available at https://gist.github.com/fxm90/8b6c9753f12fcf19991f6c3f0cd635d3
//  Modified by Diogo Silva on 11/14/20.

import MapKit
import Combine

final class LocationManager: NSObject {
    // MARK: - Public properties

    /// Publisher reporting the latitude, longitude, and course information reported by the system.
    ///
    /// - Note: We hide any details to the underlying publisher by calling `eraseToAnyPublisher()`.
    ///         This makes sure our **public property** is **immutable**.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/corelocation/cllocation
    var location: AnyPublisher<CLLocation, Error> {
        locationSubject.eraseToAnyPublisher()
    }

    /// Publisher indicating the app's authorization to use location services.
    ///
    /// - Note: We hide any details to the underlying publisher by calling `eraseToAnyPublisher()`.
    ///         This makes sure our **public property** is **immutable**.
    ///
    /// - SeeAlso: https://developer.apple.com/documentation/corelocation/clauthorizationstatus
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }

    /// Whether the location manager is currently monitoring location
    /// changes.
    var isMonitoring: Bool = false

    // MARK: - Private properties
    /// **Private and mutable** publisher reporting the latitude, longitude, and course information reported by the system.
    private let locationSubject = PassthroughSubject<CLLocation, Error>()

    /// **Private and mutable** publisher indicating the app's authorization to use location services.
    private lazy var authorizationStatusSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(locationManager.authorizationStatus)

    // MARK: - Dependencies
    private let locationManager = CLLocationManager()

    // MARK: - Initializer
    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.distanceFilter = 100
    }

    deinit {
        locationManager.stopUpdatingLocation()
        locationSubject.send(completion: .finished)
    }

    // MARK: - Managing monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        locationManager.stopUpdatingLocation()
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusSubject.send(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            // > If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries.
            // > The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end
            // > of the array.
            // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423615-locationmanager
            return
        }

        locationSubject.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(completion: .failure(error))
    }
}
