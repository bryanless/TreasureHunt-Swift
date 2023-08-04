//
//  ARViewModel.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 04/08/23.
//

import Foundation
import RealityKit
import CoreLocation
import Combine

enum MetalDetectorState {
    case notDetected, far, near, close

    // TODO: Implement metal detector sound
    func playSound() {
        switch self {
        case .notDetected:
            break
        case .far:
            break
        case .near:
            break
        case .close:
            break
        }
    }
}
class LocationViewModel: ObservableObject {
    private let locationManager = LocationManager.instance
    private var cancellables = Set<AnyCancellable>()
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var treasures: [Treasure] = []
    @Published var messageText: String = ""

    init() {
        addSubscribers()
    }

    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let self, let currentLoc, let initialLoc else { return }
                self.currentLocation = currentLoc
                self.initialLocation = initialLoc
                self.messageText = self.checkLocationWithinCircularRegion(coordinate: initialLoc.coordinate) ?? "None"
                self.calculateDistances(currentLocation: currentLoc, treasures: self.treasures)
            }
            .store(in: &cancellables)

        $initialLocation
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] initialLoc in
                guard let initialLoc,
                      let gameArea = self?.getGameArea(coordinate: initialLoc.coordinate) else { return }
                // Generate random treasure locations
                guard let treasures =
                        self?.generateTreasureLocationWithinRegion(
                            initialLocation: initialLoc,
                            region: gameArea,
                            treasureAmount: 5) else { return }

                self?.treasures = treasures
            }
            .store(in: &cancellables)
    }

    // MARK: Location Functions
    private func getGameArea(coordinate: CLLocationCoordinate2D) -> CLCircularRegion {
        return CLCircularRegion(center: coordinate, radius: 50, identifier: "RegionMap")
    }

    private func checkLocationWithinCircularRegion(coordinate: CLLocationCoordinate2D) -> String? {
        guard let currentLocation else { return nil }
        let region = getGameArea(coordinate: coordinate)
        if region.contains(currentLocation.coordinate) {
            // MARK: If within radius, do logic here
            return "Location is within radius"
        } else {
            return "Location is not within radius"
        }
    }

    private func checkCoordinateWithinCircularRegion(
        coordinate: CLLocationCoordinate2D,
        region: CLCircularRegion
    ) -> Bool {
        if region.contains(coordinate) {
            return true
        }

        return false
    }

    private func randomCoordinateWithinRegion(_ region: CLCircularRegion) -> CLLocation {
        // Generate random longitude within the region
        let randomLong = region.center.longitude +
        ((Double.random(in: 0...1) * 2 - 1) * region.radius / (111000.0 * cos(region.center.latitude.toRadians())))

        return CLLocation(latitude: region.center.latitude, longitude: randomLong)
    }

    private func generateTreasureLocationWithinRegion(
        initialLocation: CLLocation,
        region: CLCircularRegion,
        treasureAmount: Int
    ) -> [Treasure] {
        var treasures: [Treasure] = []

        for index in 0..<treasureAmount {
            let randomLocation =  randomCoordinateWithinRegion(region)

            let isWithinRegion = checkCoordinateWithinCircularRegion(
                coordinate: randomLocation.coordinate,
                region: region)

            let distance = initialLocation.distance(from: randomLocation)

            let treasure = Treasure(id: "treasure_\(index)", location: randomLocation, distance: distance)

            treasures.append(treasure)

        }

        return treasures
    }

    private func calculateDistances(
        currentLocation: CLLocation,
        treasures: [Treasure]
    ) {

        for (index, treasure) in treasures.enumerated() {
            let distance = currentLocation.distance(from: treasure.location)

            let updatedTreasure = treasure.updateState(distance: distance)

            self.treasures[index] = updatedTreasure

            if distance < 1 {
                // TODO: SPAWN TREASURE HERE, UPDATE TREASURE HAS SPAWNED STATE
            }
        }
    }

}
