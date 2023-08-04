//
//  ARViewModel.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 04/08/23.
//

import Foundation
import RealityKit

class ARViewModel: ObservableObject {
    @Published private var model : ARModel = ARModel()
    
    var arView : ARView {
        model.arView
    }
    
    func spawnMetalDetector() {
        let path = Bundle.main.path(forResource: "metal_detector", ofType: "usdz")!
        let url = URL(fileURLWithPath: path)
        
        let metalDetector = try? Entity.load(contentsOf: url)
        
        //        let metalDetector = ModelEntity(
        //              mesh: MeshResource.generateBox(size: 0.075),
        //              materials: [SimpleMaterial(color: .red, isMetallic: true)]
        //            )
        
        let cameraAnchor = AnchorEntity(.camera)
        
        // Move the box in front of the camera slightly, otherwise
        // it will be centered on the camera position and we will
        // be inside the box and not be able to see it
        metalDetector!.transform.translation = [0, -1.75, -3.15]
        //Rotation downwards in X for 45 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0,1,0))
        metalDetector!.transform.rotation *= simd_quatf(angle: 0.959931, axis: SIMD3<Float>(0,0,1))
        
        cameraAnchor.addChild(metalDetector!)
        model.arView.scene.addAnchor(cameraAnchor)
    }
    
}
