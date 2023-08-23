//
//  ARView.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

import ARKit
import RealityKit

class GameARView: ARView, ARSessionDelegate {
    var onTreasureTap: () -> Void = {}

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    dynamic required init?(coder decoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    convenience required init() {
        self.init(frame: UIScreen.main.bounds)
    }

    convenience init(onTreasureTap: @escaping () -> Void) {
        self.init(frame: UIScreen.main.bounds)
        self.onTreasureTap = onTreasureTap
        self.setupGestures()
    }
}
