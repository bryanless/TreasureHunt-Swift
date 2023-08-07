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

class LocationViewModel: ObservableObject {
    private let locationManager = LocationManager.instance
    private var cancellables = Set<AnyCancellable>()
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var treasures: [Treasure] = []
    @Published var shouldSpawnTreasure: Bool = false
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

        locationManager.$initialLocation
            .removeDuplicates()
            .map(mapToTreasures)
            .sink { [weak self] returnedTreasures in
                self?.treasures = returnedTreasures
            }
            .store(in: &cancellables)
    }

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

    private func randomCoordinateWithinRegion(
        _ region: CLCircularRegion,
        distanceBetweenCoordinate: CLLocationDistance
    ) -> CLLocation {
        let latitudeRange = region.radius / 111000.0 // Approximately 111000 meters in one degree latitude
        let centerLatitude = region.center.latitude

        let maxLatitude = centerLatitude + (latitudeRange / 2.0)
        let minLatitude = centerLatitude - (latitudeRange / 2.0)

        let randomLatitude = CLLocationDegrees.random(in: minLatitude...maxLatitude)

        return CLLocation(latitude: randomLatitude, longitude: region.center.longitude)
    }

    private func generateTreasureLocationWithinRegion(
        initialLocation: CLLocation,
        region: CLCircularRegion,
        treasureAmount: Int,
        distanceFromInitial: CLLocationDistance,
        distanceBetweenTreasures: CLLocationDistance
    ) -> [Treasure] {
        var treasures: [Treasure] = []

        while treasures.count <= treasureAmount {
            let randomLocation = randomCoordinateWithinRegion(
                region,
                distanceBetweenCoordinate: distanceBetweenTreasures)
            let isWithinRegion = checkCoordinateWithinCircularRegion(
                coordinate: randomLocation.coordinate,
                region: region)
            let distanceFromInitialLocation = randomLocation.distance(from: initialLocation)

            if isWithinRegion && distanceFromInitialLocation >= distanceFromInitial {
                let isValidLocation = treasures.allSatisfy {
                    $0.location.distance(from: randomLocation) >= distanceBetweenTreasures }
                if isValidLocation {
                    let distance = initialLocation.distance(from: randomLocation)
                    let treasure = Treasure(
                        id: "treasure_\(treasures.count - 1)",
                        location: randomLocation,
                        distance: distance)
                    treasures.append(treasure)
                }
            }
        }
        debugPrint(treasures[0].location.coordinate)
        debugPrint(treasures[1].location.coordinate)
        debugPrint(treasures[2].location.coordinate)
        debugPrint(treasures[3].location.coordinate)
        debugPrint(treasures[4].location.coordinate)
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

            if distance < 1 && !updatedTreasure.hasSpawned {
                // TODO: SPAWN TREASURE HERE, UPDATE TREASURE HAS SPAWNED STATE
                shouldSpawnTreasure = true
            }
        }
    }

    private func mapToTreasures(initialLocation: CLLocation?) -> [Treasure] {
        guard let initialLocation else { return [] }
        let gameArea = getGameArea(coordinate: initialLocation.coordinate)
        // Generate random treasure locations
        let treasures = generateTreasureLocationWithinRegion(
            initialLocation: initialLocation,
            region: gameArea,
            treasureAmount: 5,
            distanceFromInitial: 5,
            distanceBetweenTreasures: 3)
        return treasures
    }
}
