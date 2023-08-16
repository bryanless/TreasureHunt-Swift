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
    
    func checkLocationWithinCircularRegion(coordinate: CLLocationCoordinate2D) -> String? {
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
            
            self.treasures[index] = updatedTreasure
        }
        
        treasureDistance = treasures.filter { !$0.hasSpawned }.min(by: { $0.distance < $1.distance })?.distance
        playSoundBasedOnDistance(distance: treasureDistance)
        //debugPrint(currentLocation.coordinate.latitude)
        //debugPrint(self.treasures[0].location.coordinate.latitude)
    }
    
    func mapToTreasures(initialLocation: CLLocation?) -> [Treasure] {
        guard let initialLocation else { return [] }
        let gameArea = getGameArea(coordinate: initialLocation.coordinate)
        // Generate random treasure locations
        let treasures = generateTreasureLocationWithinRegion(
            initialLocation: initialLocation,
            region: gameArea,
            treasureAmount: 1,
            distanceFromInitial: 15,
            distanceBetweenTreasures: 20)
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
