//
//  LocationManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 02/08/23.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let instance = LocationManager()
    @Published var location: CLLocation?
    private let locationManager = CLLocationManager()
    @Published var initialLocation: CLLocation?
    @Published var horizontalAccuracy: CLLocationAccuracy?
    @Published var lastLocation: CLLocation?

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }

        if initialLocation == nil && currentLocation.horizontalAccuracy < 40 {
            initialLocation = currentLocation
            location = initialLocation
            lastLocation = initialLocation
        }

        guard let lastLocation = self.location else {
            self.location = currentLocation
            return
        }

        // Ignore invalid longitude and latitude
        guard currentLocation.horizontalAccuracy > 0 else { return }

        self.lastLocation = lastLocation
        horizontalAccuracy = currentLocation.horizontalAccuracy

        if currentLocation.distance(from: lastLocation) >= currentLocation.horizontalAccuracy * 0.5 {
            self.location = currentLocation
        }
    }

    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}
