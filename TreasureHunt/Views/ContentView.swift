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
            Image("board-game")
                .resizable()
                .scaledToFit()
                .opacity(0.8)
            if let location = gameVM.currentLocation,
               let treasureDistance = gameVM.treasureDistance, (((gameVM.gameData?.joinedPlayers.allSatisfy({ player in
                   return player.isGameLoaded
               }))) != false) {
                VStack {
                    //                    Text("Last location: \(LocationManager.instance.lastLocation?.coordinate.latitude.description ?? "")")
                    //                    Text("Location Latitude: \(location.coordinate.latitude)")
                    //                    Text(LocationManager.instance.horizontalAccuracy?.description ?? "0")
                    //                    Text(gameVM.metalDetectorState.rawValue)
                    //                        .fontWeight(.bold)
                    //                        .foregroundColor(.red)
                    //                    Text("Treasure Distance: \(treasureDistance.description)")
                    //                        .fontWeight(.bold)
                    //                        .foregroundColor(.blue)
                    //                    gameVM.messageText
                    Text(gameVM.messageText ?? false ? "" : "You Are Outside \nThe Playing Radius")
                        .font(.custom("FingerPaint-Regular", size: 24))
                        .foregroundColor(.red)
                    //                    Text(gameVM.messageText ?? false ? "Location is Within Radius" : "You Are Outside Playing Radius")
                    //                        .opacity((gameVM.messageText ?? false) ? 1 : 0)
                    HStack{
                        Text("Time Remaining: ")
                            .font(.custom("FingerPaint-Regular", size: 24))
                            .foregroundColor(.black)
                        Text("\(gameVM.timeRemaining?.shortTimer ?? "00:00")")
                            .font(.custom("FingerPaint-Regular", size: 24))
                            .foregroundColor(.yellow)
                    }
                    Text("\(gameVM.gameData?.treasuresFound.description ?? "0")/3 treasures found!")
                        .font(.custom("FingerPaint-Regular", size: 24))
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding(.top, 88)
                .onAppear {
                    gameVM.startTimer()
                }
            } else {
                VStack {
                    Text("Waiting for other players..")
                        .font(.custom("FingerPaint-Regular", size: 24))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding(.top, 88)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .ignoresSafeArea(edges: .top)
    }
}
