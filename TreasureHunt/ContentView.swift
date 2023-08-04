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
    @StateObject var arVM = ARViewModel()
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(arVM: arVM).edgesIgnoringSafeArea(.all)
            if let location = locationVM.currentLocation {
                VStack {
                    Text("Location Latitude: \(location.latitude)")
                    Text(locationVM.messageText)
                }
                .padding()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    var arVM: ARViewModel
    func makeUIView(context: Context) -> ARView {
        arVM.spawnMetalDetector()
        return arVM.arView
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
