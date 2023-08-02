//
//  LocationViewModel.swift
//  TestingLocation
//
//  Created by Kevin Sander Utomo on 02/08/23.
//

import Foundation
import CoreLocation
import Combine

class LocationViewModel: ObservableObject {
    private let locationManager = LocationManager.instance
    private var cancellables = Set<AnyCancellable>()
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    @Published var initialLocation: CLLocationCoordinate2D? = nil
    @Published var messageText: String = ""
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let currentLoc, let initialLoc else { return }
                self?.currentLocation = CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
                self?.initialLocation = CLLocationCoordinate2D(latitude: initialLoc.coordinate.latitude, longitude: initialLoc.coordinate.longitude)
                self?.messageText = self?.checkLocationWithinCircularRegion(coordinate: self?.initialLocation) ?? "None"
            }
            .store(in: &cancellables)
    }
    
    private func getGameArea(coordinate: CLLocationCoordinate2D) -> CLCircularRegion? {
        return CLCircularRegion(center: coordinate, radius: 50, identifier: "RegionMap")
    }
    
    private func checkLocationWithinCircularRegion(coordinate: CLLocationCoordinate2D?) -> String? {
        guard let coordinate, let region = getGameArea(coordinate: coordinate), let currentLocation else { return nil }
        if region.contains(currentLocation) {
            // MARK: If within radius, do logic here
            return "Location is within radius"
        } else {
            return "Location is not within radius"
        }
    }
    
}

