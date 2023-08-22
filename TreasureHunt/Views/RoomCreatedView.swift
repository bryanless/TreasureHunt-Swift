//
//  RoomCreatedView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 13/08/23.
//

import SwiftUI

struct RoomCreatedView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Binding var navigateToRoom: Bool
    @Environment(\.dismiss) var dismiss
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Image("background-main-menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            Image("current-players-board")
                .resizable()
                .scaledToFit()
                .frame(width: Phone.screenSize * 1.2)
                .edgesIgnoringSafeArea(.all)
            mainSection
                .navigationBarBackButtonHidden()
                .onReceive(timer, perform: { _ in
                    if gameVM.countdownStart {
                        gameVM.readyCountdown -= 1
                    }
                    
                    if gameVM.readyCountdown == 0 {
                        gameVM.startGame()
                    }
                })
            backButton
        }
        
    }
}

extension RoomCreatedView {
    
    private var backButton: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    revokeRoomSession()
                    if gameVM.isHost {
                        navigateToRoom.toggle()
                    } else {
                        dismiss.callAsFunction()
                    }
                } label: {
                    Image("back-button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Phone.screenSize * 0.15)
                }
                Spacer()
            }.frame(width: Phone.screenSize * 0.9)
            Spacer()
        }.frame(width: Phone.screenSize * 0.9)
    }
    
    private var mainSection: some View {
        VStack {
            VStack {
                ScrollView{
                    ForEach((gameVM.gameManager?.gameData.joinedPlayers)!, id: \.self) { player in
                        ZStack {
                            Image("board")
                                .resizable()
                                .scaledToFit()
                                .frame(width: Phone.screenSize * 1.1)
                            HStack {
                                Spacer()
                                Text(player.peerName)
                                    .font(.custom("FingerPaint-Regular", size: 16))
                                Spacer()
                                Image(player.isReady ? "check-board" : "cross-board")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32)
                                Spacer()
                            }.offset(y: -3)
                        }.frame(width: 440, alignment: .leading)
                    }
                    readyButton
                }.offset(y: 128)
            }
            if gameVM.countdownStart {
                VStack {
                    Text("Game Starts in \(gameVM.readyCountdown)!")
                        .font(.custom("FingerPaint-Regular", size: 16))
                }
            } else {
                VStack {
                    Text("Waiting for all players to ready up!")
                        .font(.custom("FingerPaint-Regular", size: 16))
                }
            }
        }
    }
    
    private var readyButton: some View {
        Button {
            guard let gameManager = gameVM.gameManager else { return }
            for (index, player) in gameVM.gameData!.joinedPlayers.enumerated() {
                if player.displayName == gameVM.currentPeer?.displayName {
                    gameVM.gameManager?.gameData.joinedPlayers[index].isReady.toggle()
                    gameManager.sendToPeersGameData(data: gameManager.gameData)
                }
            }
        } label: {
            ForEach(gameVM.gameData!.joinedPlayers) { player in
                if player.displayName == gameVM.currentPeer?.displayName {
                    if (!player.isReady){
                        Image("ready-board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Phone.screenSize * 1.2)
                    } else {
                        Image("cancel-board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Phone.screenSize * 1.2)
                    }
                }
            }
        }
    }
    private func revokeRoomSession() {
        if (gameVM.gameManager?.isHost == true) {
            gameVM.gameManager?.stopAdvertising()
            gameVM.gameManager?.isHost = false
        }
        gameVM.gameManager?.gameData = GameData.dataInstance()
        gameVM.gameManager?.session.disconnect()
        gameVM.gameManager?.startBrowsing()
    }
}
