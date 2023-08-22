//
//  GameViewModel+Location.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation
import CoreLocation

extension GameViewModel {
    private func getGameArea(coordinate: CLLocationCoordinate2D) -> CLCircularRegion {
        return CLCircularRegion(center: coordinate, radius: 100, identifier: "RegionMap")
    }
    
    func checkLocationWithinCircularRegion(coordinate: CLLocationCoordinate2D) -> Bool? {
        guard let currentLocation else { return nil }
        let region = getGameArea(coordinate: coordinate)
        if region.contains(currentLocation.coordinate) {
            // MARK: If within radius, do logic here
            return true
        } else {
            return false
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
    
    private func generateTreasureLocationsWithinRegion(
        initialLocation: CLLocation,
        region: CLCircularRegion,
        treasureAmount: Int,
        distanceFromInitial: CLLocationDistance,
        distanceBetweenTreasures: CLLocationDistance
    ) -> [Treasure] {
        var treasures: [Treasure] = []

        while treasures.count < treasureAmount {
            let randomLocation = randomCoordinateWithinRegion(
                region,
                distanceBetweenCoordinate: distanceBetweenTreasures)
            let isWithinRegion = checkCoordinateWithinCircularRegion(
                coordinate: randomLocation.coordinate,
                region: region)
            let distanceFromInitialLocation = randomLocation.distance(from: initialLocation)

            if isWithinRegion && distanceFromInitialLocation >= distanceFromInitial {
                let isValidLocation = treasures.allSatisfy {
                    $0.location.distance(from: randomLocation) >= distanceBetweenTreasures
                } && randomLocation.distance(from: initialLocation) >= distanceFromInitial
                if isValidLocation {
                    let distance = initialLocation.distance(from: randomLocation)
                    let treasure = Treasure(
                        id: "treasure_\(treasures.count)",
                        location: randomLocation,
                        distance: distance)
                    treasures.append(treasure)
                }
            }
        }
        print(treasures.count)
        return treasures
    }


    
    func calculateDistances(
        currentLocation: CLLocation,
        treasures: [Treasure]
    ) {
        
        for (index, treasure) in treasures.enumerated() {
            let distance = currentLocation.distance(from: treasure.location)
            var updatedTreasure = treasure.updateState(distance: distance)
            
            if distance < 10 && !updatedTreasure.hasSpawned {
                // TODO: SPAWN TREASURE HERE, UPDATE TREASURE HAS SPAWNED STATE
                updatedTreasure.hasSpawned = true
                shouldSpawnTreasure = true
            }
            
            self.gameManager?.gameData.treasures[index] = updatedTreasure
            gameManager?.sendToPeersGameData(data: gameManager!.gameData)
        }
        
        treasureDistance = treasures.filter { !$0.hasSpawned }.min(by: { $0.distance < $1.distance })?.distance
        playSoundBasedOnDistance(distance: treasureDistance)
    }
    
    func mapToTreasures(initialLocation: CLLocation?) -> [Treasure] {
        guard let initialLocation else { return [] }
        let gameArea = getGameArea(coordinate: initialLocation.coordinate)
        // Generate random treasure locations
        let treasures = generateTreasureLocationsWithinRegion(
            initialLocation: initialLocation,
            region: gameArea,
            treasureAmount: 3,
            distanceFromInitial: 15,
            distanceBetweenTreasures: 12)
        return treasures
    }
    
    private func playSoundBasedOnDistance(distance: CLLocationDistance?) {
        guard let distance = distance else { return }
        
        if distance < 20 {
            metalDetectorState = .close
        } else if distance < 40 {
            metalDetectorState = .far
        } else {
            metalDetectorState = .notDetected
        }
    }
}
