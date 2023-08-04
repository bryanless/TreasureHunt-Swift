//
//  Treasure.swift
//  TreasureHunt
//
//  Created by Bryan on 04/08/23.
//

import CoreLocation

struct Treasure: Identifiable {
    let id: String
    let location: CLLocation
    var distance: CLLocationDistance
    var hasSpawned: Bool = false

    func updateState(
        distance: CLLocationDistance? = nil,
        hasSpawned: Bool? = nil
    ) -> Treasure {
        return Treasure(id: self.id, location: self.location, distance: distance ?? self.distance, hasSpawned: hasSpawned ?? self.hasSpawned)
    }
}
