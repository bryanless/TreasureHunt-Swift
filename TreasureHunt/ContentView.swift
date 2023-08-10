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
        VStack {
            switch gameVM.gameState {
            case .start:
                startGame
            case .notStart:
                MainMenuView()
            case .end:
                EndGameView()
            case .none:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: gameVM.gameState)
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

extension ContentView {

    private var startGame: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            gameOverlay
        }
    }
    private var gameOverlay: some View {
        VStack {
            if let location = gameVM.currentLocation, let treasureDistance = gameVM.treasureDistance, let time = gameVM.timeRemaining {
                Text("Location Latitude: \(location.coordinate.latitude)")
                Text(gameVM.metalDetectorState.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Text("Treasure Distance: \(treasureDistance.description)")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text(gameVM.messageText)
                Text(time.shortTimer)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}
