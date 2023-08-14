//
//  TreasureAREntity.swift
//  TreasureHunt
//
//  Created by Bryan on 09/08/23.
//

import Foundation
import RealityKit

class TreasureAREntity: Entity, HasCollision {
    #if !targetEnvironment(simulator)
    let myAnchor = AnchorEntity(plane: .horizontal)
    #else
    let myAnchor = AnchorEntity()
    #endif

    required init() {
        super.init()
        // Add Metal Detector from Models in Bundle
        let treasureAssetPath = Bundle.main.path(forResource: "treasure", ofType: "usdz")!
        // Add URL Path from Bundle
        let treasureUrl = URL(fileURLWithPath: treasureAssetPath)
        let treasure = try? Entity.load(contentsOf: treasureUrl)

        treasure?.transform.scale *= 0.05

        treasure?.generateCollisionShapes(recursive: true)

        // ARView gestures detect which gesture that can be triggered by certain entity by using its name
        myAnchor.name = "treasure"

        myAnchor.addChild(treasure!)
    }

    func getAnchor() -> AnchorEntity {
        return myAnchor
    }
}
