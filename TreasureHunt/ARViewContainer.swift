//
//  ARViewRepresentable.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject var motion = MotionManager()
    // Anchor from Camera
    let cameraAnchor = AnchorEntity(.camera)

    func makeUIView(context: Context) -> GameARView {
        // Add ARView to call
        let arView = GameARView(onTreasureTap: gameViewModel.increaseFoundTreasure)

        // Load Entity to Metal Detector
        gameViewModel.loadEntityAsync(
            fileName: "metal_detector",
            fileExtension: "usdz"
        ) { result in
            switch result {
            case .success(let metalDetector):
                metalDetector.name = "metalDetector"
                // Add Metal Detector Right On Camera
                cameraAnchor.addChild(metalDetector)
                // Add Camera Anchor to the Scene after adding child
                arView.scene.addAnchor(cameraAnchor)
                // Move Metal Detector Downwards and Front
                metalDetector.transform.translation = [0, -1.75, -3.15]
                // Rotation downwards in X for 90 degrees
                metalDetector.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0, 1, 0))
                // Rotation downwards in z for 50 degrees
                metalDetector.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0, 0, 1))

                gameViewModel.startGame()
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }

        return arView
    }

    func updateUIView(_ uiView: GameARView, context: Context) {
        if gameViewModel.shouldSpawnTreasure {
            let treasureAnchor = TreasureAREntity().getAnchor()
            uiView.scene.addAnchor(treasureAnchor)
            DispatchQueue.main.async {
                gameViewModel.shouldSpawnTreasure = false
            }
        }

        guard let metalDetector = uiView.scene.anchors.first?.children.first else { return }

        if metalDetector.transform.rotation.real < 0.6268
            || metalDetector.transform.rotation.real > 0.62758 {
            uiView.scene.anchors[0].children[0].transform.rotation *=
            simd_quatf(angle: Float(motion.x * 0.00002125), axis: SIMD3<Float>(1, 0, 0))
        } else {
            metalDetector.transform.rotation *=
            simd_quatf(angle: Float(motion.x * 0.00002125), axis: SIMD3<Float>(1, 0, 0))
            metalDetector.transform.translation += [Float(motion.x * 0.0005), 0, 0]
        }
    }

}
