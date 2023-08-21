//
//  CLLocationDegreesExt.swift
//  TreasureHunt
//
//  Created by Bryan on 02/08/23.
//

import CoreLocation

extension CLLocationDegrees {
    func toRadians() -> CLLocationDegrees {
        return self * .pi / 180
    }
}
