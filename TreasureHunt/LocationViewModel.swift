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

        locationManager.$initialLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] initialLoc in
                guard let initialLoc else { return }

                // Generate random treasure locations
                let gameArea = self?.getGameArea(coordinate: initialLoc.coordinate)
                let _ = self?.generateRandomLocationWithinRegion(region: gameArea!, locationAmount: 5)
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

    private func checkCoordinateWithinCircularRegion(coordinate: CLLocationCoordinate2D, region: CLCircularRegion) -> Bool {
        if region.contains(coordinate) {
            return true
        }

        return false
    }

    private func randomCoordinateWithinRegion(_ region: CLCircularRegion) -> CLLocationCoordinate2D {
        // Generate random latitude within the region
//        let minLat = region.center.latitude - region.radius / 111000.0
//        let maxLat = region.center.latitude + region.radius / 111000.0
//        let randomLat = CLLocationDegrees.random(in: minLat...maxLat)

        // Generate random longitude within the region
        let randomLong = region.center.longitude + (Double.random(in: 0...1) * 2 - 1) * region.radius / (111000.0 * cos(region.center.latitude.toRadians()))

        return CLLocationCoordinate2D(latitude: region.center.latitude, longitude: randomLong)
    }

    private func generateRandomLocationWithinRegion(
        region: CLCircularRegion,
        locationAmount: Int) -> [CLLocationCoordinate2D] {
        var randomLocations: [CLLocationCoordinate2D] = []

        for _ in 0..<locationAmount {
            let randomLocation =  randomCoordinateWithinRegion(region)

            let isWithinRegion = checkCoordinateWithinCircularRegion(
                coordinate: randomLocation,
                region: region)

            debugPrint(isWithinRegion)

            randomLocations.append(randomLocation)

        }

        return randomLocations
    }
    
}

