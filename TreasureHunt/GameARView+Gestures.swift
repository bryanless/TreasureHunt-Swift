//
//  ARObjectInteraction.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

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

        guard let hitEntity = self.entity(at: touchLocation) else {
            return
        }

        // Only entity named "treasure" can be removed
        guard hitEntity.anchor?.findEntity(named: "treasure")?.name == "treasure" else { return }
        //TODO: Animation
        self.scene.removeAnchor(hitEntity.anchor!)

        self.onTreasureTap()
    }
}
