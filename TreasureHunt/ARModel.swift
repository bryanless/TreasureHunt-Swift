//
//  ARModel.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 04/08/23.
//

import Foundation
import RealityKit

struct ARModel {
    private(set) var arView : ARView
    
    init() {
        arView = ARView(frame: .zero)
    }
    
}
