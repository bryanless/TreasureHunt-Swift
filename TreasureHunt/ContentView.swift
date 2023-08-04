//
//  ContentView.swift
//  TreasureHunt
//
//  Created by Bryan on 02/08/23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @StateObject var locationVM = LocationViewModel()
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
//            if let location = locationVM.currentLocation {
//                VStack {
//                    Text("Location Latitude: \(location.latitude)")
//                    Text(locationVM.messageText)
//                }
//                .padding()
//            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        //Add ARView to call
        let arView = ARView(frame: .zero)
        //Add Metal Detector from Models in Bundle
        let path = Bundle.main.path(forResource: "metal_detector", ofType: "usdz")!
        //Add URL Path from Bundle
        let url = URL(fileURLWithPath: path)
        //Load Entity to Metal Detector
        let metalDetector = try? Entity.load(contentsOf: url)
        //Anchor from Camera
        let cameraAnchor = AnchorEntity(.camera)
        
        //Add Metal Detector Right On Camera
        cameraAnchor.addChild(metalDetector!)
        //Add Camera Anchor to the Scene after adding child
        arView.scene.addAnchor(cameraAnchor)

        // Move Metal Detector Downwards and Front
        metalDetector!.transform.translation = [0, -1.75, -3.15]
        //Rotation downwards in X for 90 degrees
        metalDetector!.transform.rotation *= simd_quatf(angle: 1.5708, axis: SIMD3<Float>(0,1,0))
        //Rotation downwards in z for 50 degrees
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
