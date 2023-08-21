//
//  ContentView.swift
//  TreasureHunt
//
//  Created by Bryan on 02/08/23.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject var gameVM: GameViewModel = GameViewModel()

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
        ZStack(alignment: .top) {
            if let location = gameVM.currentLocation,
               let treasureDistance = gameVM.treasureDistance,
               let time = gameVM.timeRemaining {
                Image("board-game")
                    .resizable()
                    .scaledToFit()
                VStack {
                    Text("Last location: \(LocationManager.instance.lastLocation?.coordinate.latitude.description ?? "")")
                    Text("Location Latitude: \(location.coordinate.latitude)")
                    Text(LocationManager.instance.horizontalAccuracy?.description ?? "0")
                    Text(gameVM.metalDetectorState.rawValue)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Treasure Distance: \(treasureDistance.description)")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text(gameVM.messageText ?? false ? "Location is Within Radius" : "None")
                        .opacity((gameVM.messageText ?? false) ? 1 : 0)
                    Text(time.shortTimer)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text(gameVM.gameData?.treasuresFound.description ?? "0")
                    Spacer()
                }
                .padding(.top, 88)
            } else {
                //TODO: LoadingView()
//                LoadingView()
//                Text("Current location accuracy is \(LocationManager.instance.horizontalAccuracy ?? 0), which is higher than 20, please wait")
//                    .multilineTextAlignment(.center)
            }
        }
        .foregroundColor(.white)
        .ignoresSafeArea(edges: .top)
    }
}