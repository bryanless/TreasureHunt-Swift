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
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 2
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let firstLocation = locations.first else { return }
        if initialLocation == nil {
            initialLocation = firstLocation
        }
        guard let lastLocation = self.location else {
            self.location = initialLocation
            return
        }
        
        if location.distance(from: lastLocation) >= location.horizontalAccuracy * 2 {
            self.location = location
        }
    }

    func stopLocation() {
        locationManager.stopUpdatingLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}
