//
//  ContentView.swift
//  TreasureHunt
//
//  Created by Bryan on 02/08/23.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var gameVM = GameViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            if let location = gameVM.currentLocation, let treasureDistance = gameVM.treasureDistance {
                VStack {
                    Text("Location Latitude: \(location.coordinate.latitude)")
                    Text(gameVM.metalDetectorState.rawValue)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Treasure Distance: \(treasureDistance.description)")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(gameVM.messageText)
                }
                .padding()
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    // Add MotionManager
    @StateObject var motion = MotionManager()
    // Anchor from Camera
    let cameraAnchor = AnchorEntity(.camera)

    func makeUIView(context: Context) -> ARView {
        // Add ARView to call
        let arView = ARView(frame: .zero)
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

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
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

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
