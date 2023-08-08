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

class GameViewModel: ObservableObject {
    private let locationManager = LocationManager.instance
    private let gameManager = GameManager.instance
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @Published var count: Int = 0
    @Published var treasuresFound: Int = 0
    @Published var gameState: GameState? = nil
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var treasureDistance: CLLocationDistance?
    @Published var treasures: [Treasure] = []
    @Published var shouldSpawnTreasure: Bool = false
    @Published var messageText: String = ""
    @Published var metalDetectorState: MetalDetectorState = .notDetected

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

        $metalDetectorState
            .removeDuplicates()
            .sink { returnedState in
                returnedState.playSound()
            }
            .store(in: &cancellables)

        gameManager.$gameState
            .sink { [weak self] gameState in
                self?.gameState = gameState
            }
            .store(in: &cancellables)

        gameManager.$treasuresFound
            .sink { [weak self] foundTreasures in
                self?.treasuresFound = foundTreasures
            }
            .store(in: &cancellables)

        $gameState
            .sink { [weak self] gameState in
                guard let gameState else { return }
                switch gameState {
                case .notStart:
                    return
                case .start:
                    self?.gameManager.startGame()
                case .end:
                    self?.gameManager.endGame()
                }
            }
            .store(in: &cancellables)
    }

    private func getGameArea(coordinate: CLLocationCoordinate2D) -> CLCircularRegion {
        return CLCircularRegion(center: coordinate, radius: 100, identifier: "RegionMap")
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
        //        debugPrint(treasures[0].location.coordinate)
        //        debugPrint(treasures[1].location.coordinate)
        //        debugPrint(treasures[2].location.coordinate)
        //        debugPrint(treasures[3].location.coordinate)
        //        debugPrint(treasures[4].location.coordinate)
        return treasures
    }

    private func calculateDistances(
        currentLocation: CLLocation,
        treasures: [Treasure]
    ) {

        for (index, treasure) in treasures.enumerated() {
            let distance = currentLocation.distance(from: treasure.location)
            var updatedTreasure = treasure.updateState(distance: distance)

            playSoundBasedOnDistance()
            if distance < 10 && !updatedTreasure.hasSpawned {
                // TODO: SPAWN TREASURE HERE, UPDATE TREASURE HAS SPAWNED STATE
                shouldSpawnTreasure = true
                updatedTreasure.hasSpawned = true
            }

            self.treasures[index] = updatedTreasure
        }
        treasureDistance = treasures.first?.distance
        //debugPrint(currentLocation.coordinate.latitude)
        //debugPrint(self.treasures[0].location.coordinate.latitude)
    }

    private func mapToTreasures(initialLocation: CLLocation?) -> [Treasure] {
        guard let initialLocation else { return [] }
        let gameArea = getGameArea(coordinate: initialLocation.coordinate)
        // Generate random treasure locations
        let treasures = generateTreasureLocationWithinRegion(
            initialLocation: initialLocation,
            region: gameArea,
            treasureAmount: 1,
            distanceFromInitial: 10,
            distanceBetweenTreasures: 20)
        return treasures
    }

    private func playSoundBasedOnDistance() {
        if treasures.contains(where: { $0.distance < 20 }) {
            debugPrint("close")
            metalDetectorState = .close
        } else if treasures.contains(where: { $0.distance < 40 }) {
            debugPrint("far")
            metalDetectorState = .far
        } else {
            metalDetectorState = .notDetected
        }
    }

    private func increaseFoundTreasure() {
        gameManager.increaseFound()
    }

}
