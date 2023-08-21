//
//  TreasureAREntity.swift
//  TreasureHunt
//
//  Created by Bryan on 09/08/23.
//

import Foundation
import RealityKit

class TreasureAREntity: Entity, HasCollision {
    func load(completion: @escaping (Result<Entity, Error>) -> Void) {
        Entity.loadEntityAsync(
            fileName: "treasure",
            fileExtension: "usdz",
            completion: { result in
                switch result {
                case .success(let treasure):
                    treasure.transform.scale *= 0.1
                    treasure.generateCollisionShapes(recursive: true)

                    completion(.success(treasure))
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            })
    }
}
