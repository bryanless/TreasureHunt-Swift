//
//  ARViewRepresentable.swift
//  TreasureHunt
//
//  Created by Bryan on 08/08/23.
//

import RealityKit
import ARKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var gameViewModel: GameViewModel
    @StateObject var motion = MotionManager()
    // Anchor from Camera
    let cameraAnchor = AnchorEntity(.camera)

    func makeUIView(context: Context) -> GameARView {
        //
        //        gameViewModel.sessionIDObservation = arView.session.observe(\.identifier, options: [.new]) { object, change in
        //            print("SessionID changed to: \(change.newValue!)")
        //            // Tell all other peers about your ARSession's changed ID, so
        //            // that they can keep track of which ARAnchors are yours.
        //            guard let multipeerSession = self.gameViewModel.gameManager else { return }
        //            gameViewModel.sendARSessionIDTo(peers: gameViewModel.gameManager!.connectedPeers, arView: arView)
        //        }

        guard let gameAR = gameViewModel.arView else { return GameARView(onTreasureTap: {})}
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
                gameAR.scene.addAnchor(cameraAnchor)
                // Move Metal Detector Downwards and Front
                metalDetector.transform.translation = [0, -1.75, -3.15]
                // Rotation downwards in X for 90 degrees
                metalDetector.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0, 1, 0))
                // Rotation downwards in z for 50 degrees
                metalDetector.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0, 0, 1))

        // Setup interaction gestures
//        arView.setupGestures()

        return gameAR
    }

    func updateUIView(_ uiView: GameARView, context: Context) {
//        debugPrint(gameViewModel.shouldSpawnTreasure)
//                if gameViewModel.shouldSpawnTreasure {
        if gameViewModel.shouldSpawnTreasure {
            let treasureAnchor = TreasureAREntity().getAnchor()
            uiView.scene.addAnchor(treasureAnchor)
            DispatchQueue.main.async {
                gameViewModel.shouldSpawnTreasure = false
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

//extension ARViewContainer {
//    class Coordinator: NSObject, ARSessionDelegate {
//        var parent: ARViewContainer
//
//        init(parent: ARViewContainer) {
//            self.parent = parent
//        }
//
//        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//            for anchor in anchors {
//                if let participantAnchor = anchor as? ARParticipantAnchor {
//                    print("Established joint experience with peer")
//                }
//            }
//        }
//
//        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
//            guard let multipeerSession = self.parent.gameViewModel.gameManager else { return }
//            if !multipeerSession.connectedPeers.isEmpty {
//                guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
//                else { fatalError("Unexpectedly failed to encode collaboration data.") }
//                // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
//                multipeerSession.sendToPeersARData(data: encodedData)
//            } else {
//                print("Deferred sending collaboration to later because there are no peers.")
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//}

