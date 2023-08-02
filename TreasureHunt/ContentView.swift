//
//  ContentView.swift
//  TreasureHunt
//
//  Created by Bryan on 02/08/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let path = Bundle.main.path(forResource: "metal_detector", ofType: "usdz")!
        let url = URL(fileURLWithPath: path)
        
        let metalDetector = try? Entity.load(contentsOf: url)

//        let metalDetector = ModelEntity(
//              mesh: MeshResource.generateBox(size: 0.075),
//              materials: [SimpleMaterial(color: .red, isMetallic: true)]
//            )

        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.addChild(metalDetector!)
        arView.scene.addAnchor(cameraAnchor)

        // Move the box in front of the camera slightly, otherwise
            // it will be centered on the camera position and we will
            // be inside the box and not be able to see it
        metalDetector!.transform.translation = [0, -1.75, -3.15]
        //Rotation downwards in X for 45 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0,1,0))
        metalDetector!.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0,0,1))
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
