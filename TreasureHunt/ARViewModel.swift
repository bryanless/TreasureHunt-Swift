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

class ARViewModel: ObservableObject {
    @Published private var model: ARModel = ARModel()
    private let locationManager = LocationManager.instance
    private var cancellables = Set<AnyCancellable>()
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var itemLocations: [CLLocation] = []
    @Published var messageText: String = ""
    init() {
        addSubscribers()
    }
    var arView: ARView {
        model.arView
    }
    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let self, let currentLoc, let initialLoc else { return }
                self.currentLocation = currentLoc
                self.initialLocation = initialLoc
                self.messageText = self.checkLocationWithinCircularRegion(coordinate: initialLoc.coordinate) ?? "None"
                let distances =
                self.calculateDistances(currentLocation: currentLoc, locations: self.itemLocations)
                debugPrint(distances)
            }
            .store(in: &cancellables)
        
        locationManager.$initialLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] initialLoc in
                guard let initialLoc,
                      let gameArea = self?.getGameArea(coordinate: initialLoc.coordinate) else { return }
                // TODO save random locations to a variable
                // Generate random treasure locations
                guard let locations =
                        self?.generateRandomLocationWithinRegion(region: gameArea, locationAmount: 5) else { return }
                self?.itemLocations = locations
            }
            .store(in: &cancellables)
    }
    
    //MARK: Location Functions
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
    
    private func generateRandomLocationWithinRegion(
        region: CLCircularRegion,
        locationAmount: Int
    ) -> [CLLocation] {
        var randomLocations: [CLLocation] = []
        
        for _ in 0..<locationAmount {
            let randomLocation =  randomCoordinateWithinRegion(region)
            
            let isWithinRegion = checkCoordinateWithinCircularRegion(
                coordinate: randomLocation.coordinate,
                region: region)
            
            randomLocations.append(randomLocation)
            
        }
        
        return randomLocations
    }
    
    private func calculateDistances(
        currentLocation: CLLocation,
        locations: [CLLocation]
    ) -> [CLLocationDistance] {
        var distances: [CLLocationDistance] = []
        
        for location in locations {
            let distance = currentLocation.distance(from: location)
            distances.append(distance)
        }
        
        return distances
    }
    
    
    //MARK: AR Functions
    func spawnMetalDetector() {
        let path = Bundle.main.path(forResource: "metal_detector", ofType: "usdz")!
        let url = URL(fileURLWithPath: path)
        
        let metalDetector = try? Entity.load(contentsOf: url)
        
        //        let metalDetector = ModelEntity(
        //              mesh: MeshResource.generateBox(size: 0.075),
        //              materials: [SimpleMaterial(color: .red, isMetallic: true)]
        //            )
        
        let cameraAnchor = AnchorEntity(.camera)
        
        // Move the box in front of the camera slightly, otherwise
        // it will be centered on the camera position and we will
        // be inside the box and not be able to see it
        metalDetector!.transform.translation = [0, -1.75, -3.15]
        //Rotation downwards in X for 45 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0,1,0))
        metalDetector!.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0,0,1))
        
        cameraAnchor.addChild(metalDetector!)
        model.arView.scene.addAnchor(cameraAnchor)
    }
    
}
