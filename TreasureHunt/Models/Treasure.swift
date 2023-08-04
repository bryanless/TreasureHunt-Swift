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

    func updateDistance(distance: CLLocationDistance) -> Treasure {
        return Treasure(id: self.id, location: self.location, distance: distance)
    }
}
