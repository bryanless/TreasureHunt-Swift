//
//  ARObjectInteraction.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

import ARKit
import Foundation
import RealityKit
import UIKit

extension GameARView {
    func setupGestures() {
        let treasureTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onTreasureTap(_:)))
        self.addGestureRecognizer(treasureTapGesture)
    }

    @objc func onTreasureTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: self)

        // Return if no entity is tapped
        guard let hitEntity = self.entity(at: touchLocation) else { return }

        // Ignore entity other than the one named "treasure"
        guard let entityName = hitEntity.anchor?.findEntity(named: "treasure")?.name,
              entityName == "treasure" else { return }

        // Get entity's ARAnchor
        guard let arAnchor = self.session.currentFrame?.anchors.first(where: { $0.name == entityName }) else { return }

        // Remove treasure
        // TODO: Animation
        self.session.remove(anchor: arAnchor)

        self.onTreasureTap()
    }
}
