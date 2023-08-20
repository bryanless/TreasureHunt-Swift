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

    func makeUIView(context: Context) -> GameARView {
        gameViewModel.arView?.session.delegate = context.coordinator

        return gameViewModel.arView ?? GameARView(onTreasureTap: {})
    }

    func updateUIView(_ uiView: GameARView, context: Context) {
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

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        let cameraAnchor = AnchorEntity(.camera)
        var count = 0

        init(parent: ARViewContainer) {
            self.parent = parent
        }

      func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // TODO: Remove !
        if !parent.gameViewModel.shouldSpawnTreasure {
            DispatchQueue.main.async {
                // TODO: Change true to false
                self.parent.gameViewModel.shouldSpawnTreasure = true
            }

            let spawningDistance: Float = 1

            let cameraTransform = frame.camera.transform

            // Calculate the new entity's position in front of the camera
            let cameraPosition = cameraTransform.translation

            // Calculate the forward direction based on the camera's rotation
            let forwardDirection = -cameraTransform.columns.2.xyz

            // Calculate the new position by adding the forward direction multiplied by the spawning distance
            let newPosition = cameraPosition + forwardDirection * spawningDistance

            // Create an ARAnchor using the new position
            let anchor = ARAnchor(name: "treasure", transform: simd_float4x4(translation: newPosition))

            session.add(anchor: anchor)
        }
      }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // TODO: Remove count, use participantAnchor instead
            for anchor in anchors {
                if let participantAnchor = anchor as? ARParticipantAnchor {
                    print("Established joint experience with peer")
                } else {
                    if let anchorName = anchor.name, anchorName == "treasure" {
                        TreasureAREntity().load { result in
                            switch result {
                            case .success(let treasure):
                                let treasureAnchor = AnchorEntity(anchor: anchor)
                                treasureAnchor.name = anchorName
                                treasureAnchor.addChild(treasure)
                                self.parent.gameViewModel.arView?.scene.addAnchor(treasureAnchor)
                            case .failure(let error):
                                debugPrint(error.localizedDescription)
                            }
                        }
                    }

                    if self.cameraAnchor.children.isEmpty {
                        Entity.loadEntityAsync(
                            fileName: "metal_detector",
                            fileExtension: "usdz"
                        ) { result in
                            switch result {
                            case .success(let metalDetector):
                                metalDetector.name = "metalDetector"
                                // Add Metal Detector Right On Camera
                                self.cameraAnchor.addChild(metalDetector)
                                // Add Camera Anchor to the Scene after adding child
                                self.parent.gameViewModel.arView?.scene.addAnchor(self.cameraAnchor)
                                // Move Metal Detector Downwards and Front
                                metalDetector.transform.translation = [0, -1.75, -3.15]
                                // Rotation downwards in X for 90 degrees
                                metalDetector.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0, 1, 0))
                                // Rotation downwards in z for 50 degrees
                                metalDetector.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0, 0, 1))
                            case .failure(let error):
                                debugPrint(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }

        // TODO Might not be used, remove this
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            for anchor in anchors {
                if let participantAnchor = anchor as? ARParticipantAnchor {
                    print("Established joint experience with peer")
                } else {
                    if let anchorName = anchor.name, anchorName == "treasure" {
                        debugPrint("anchor: remove \(anchorName)")
                    }
                }
            }
        }

        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
            guard let multipeerSession = self.parent.gameViewModel.gameManager else { return }
            if !multipeerSession.session.connectedPeers.isEmpty {
                guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
                // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
                multipeerSession.sendToPeersARData(data: encodedData)
            } else {
                print("Deferred sending collaboration to later because there are no peers.")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}
