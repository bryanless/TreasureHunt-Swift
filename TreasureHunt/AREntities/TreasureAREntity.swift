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
        Entity.loadEntityAsync(
            fileName: "treasure",
            fileExtension: "usdz",
            completion: { result in
                switch result {
                case .success(let treasure):
                    treasure.transform.scale *= 0.05
                    treasure.generateCollisionShapes(recursive: true)

                    // ARView gestures detect which gesture that can be triggered by certain entity by using its name
                    self.myAnchor.name = "treasure"
                    self.myAnchor.addChild(treasure)
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            })
    }

    func getAnchor() -> AnchorEntity {
        return myAnchor
    }
}
