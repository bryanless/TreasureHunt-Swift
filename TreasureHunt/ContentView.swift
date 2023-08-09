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
        .environmentObject(gameVM)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
