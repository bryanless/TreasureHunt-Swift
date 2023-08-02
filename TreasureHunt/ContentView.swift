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
        
        
        let box = ModelEntity(
              mesh: MeshResource.generateBox(size: 0.075),
              materials: [SimpleMaterial(color: .red, isMetallic: true)]
            )

        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.addChild(box)
        arView.scene.addAnchor(cameraAnchor)

        // Move the box in front of the camera slightly, otherwise
            // it will be centered on the camera position and we will
            // be inside the box and not be able to see it
        box.transform.translation = [0, -0.25, -0.75]
        //Rotation downwards in X for 45 degrees
        box.transform.rotation = simd_quatf(angle: 0.785, axis: SIMD3<Float>(1,0,0))
        
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
