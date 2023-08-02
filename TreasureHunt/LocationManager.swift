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
    @Published var location: CLLocation? = nil
    private let locationManager = CLLocationManager()
    @Published var initialLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let firstLocation = locations.first else { return }
        if initialLocation == nil {
            initialLocation = firstLocation
        }
        self.location = location
    }
}

