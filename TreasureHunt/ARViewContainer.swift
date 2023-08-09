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
    @State var count: Int = 1
    // Anchor from Camera
    let cameraAnchor = AnchorEntity(.camera)

    func makeUIView(context: Context) -> GameARView {
        // Add ARView to call
        let arView = GameARView()
        // Add Metal Detector from Models in Bundle
        let path = Bundle.main.path(forResource: "metal_detector", ofType: "usdz")!
        // Add URL Path from Bundle
        let url = URL(fileURLWithPath: path)
        // Load Entity to Metal Detector
        let metalDetector = try? Entity.load(contentsOf: url)
        metalDetector!.name = "metalDetector"
        // Add Metal Detector Right On Camera
        cameraAnchor.addChild(metalDetector!)
        // Add Camera Anchor to the Scene after adding child
        arView.scene.addAnchor(cameraAnchor)
        // Move Metal Detector Downwards and Front
        metalDetector!.transform.translation = [0, -1.75, -3.15]
        // Rotation downwards in X for 90 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0, 1, 0))
        // Rotation downwards in z for 50 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0, 0, 1))

        // Setup interaction gestures
//        arView.setupGestures()

        return arView
    }

    func updateUIView(_ uiView: GameARView, context: Context) {
//        debugPrint(gameViewModel.shouldSpawnTreasure)
//                if gameViewModel.shouldSpawnTreasure {
        if !gameViewModel.shouldSpawnTreasure && count == 1 {
            let treasureAnchor = TreasureAREntity().getAnchor()
            uiView.scene.addAnchor(treasureAnchor)
            //            gameViewModel.shouldSpawnTreasure = false
            DispatchQueue.main.async {
                count = 0
            }
        }
        if uiView.scene.anchors[0].children[0].transform.rotation.real < 0.6268
            || uiView.scene.anchors[0].children[0].transform.rotation.real > 0.62758 {
            uiView.scene.anchors[0].children[0].transform.rotation *=
            simd_quatf(angle: Float(motion.x * 0.00002125), axis: SIMD3<Float>(1, 0, 0))
        } else {
            uiView.scene.anchors[0].children[0].transform.rotation *=
            simd_quatf(angle: Float(motion.x * 0.00002125), axis: SIMD3<Float>(1, 0, 0))
            uiView.scene.anchors[0].children[0].transform.translation += [Float(motion.x * 0.0005), 0, 0]
        }
    }

}
