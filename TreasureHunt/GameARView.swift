//
//  ARView.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

import ARKit
import RealityKit

class GameARView: ARView, ARSessionDelegate {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.setupGestures()
    }
}
