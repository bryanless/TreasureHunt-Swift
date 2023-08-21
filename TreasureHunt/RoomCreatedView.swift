//
//  RoomCreatedView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 13/08/23.
//

import SwiftUI

struct RoomCreatedView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Environment(\.dismiss) var dismiss
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            Image("background-main-menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            Image("current-players-board")
                .resizable()
                .scaledToFit()
                .frame(width: 480)
                .edgesIgnoringSafeArea(.all)
            VStack {
                
                VStack {
                    ScrollView{
                        ForEach((gameVM.gameManager?.gameData.joinedPlayers)!, id: \.self) { player in
                            ZStack {
                                Image("board")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 440)
                                HStack {
                                    Spacer()
                                    Text(player.peerName)
                                        .font(.custom("FingerPaint-Regular", size: 16))
                                    Spacer()
                                    Image(systemName: "crown")
                                        .opacity(player.isHost ? 1 : 0)
                                    Image(systemName: player.isReady ? "checkmark" : "xmark")
                                        .foregroundColor(player.isReady ? .green : .red)
                                    Spacer()
                                }.offset(y: -2)
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
            .navigationBarBackButtonHidden()
            .onReceive(timer, perform: { _ in
                if gameVM.countdownStart {
                    gameVM.readyCountdown -= 1
                }
                
                if gameVM.readyCountdown == 0 {
                    gameVM.startGame()
                }
            })
            VStack{
                HStack{
                    Button(action: {
                        revokeRoomSession()
                        dismiss.callAsFunction()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Back")
                        }
                    })
                    Spacer()
                }
                .frame(width: 360)
                Spacer()
            }
        }
        
    }
}

extension RoomCreatedView {
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
                            .frame(width: 360)
                    } else {
                        Image("cancel-board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 360)
                    }
//                    Text(player.isReady ? "Cancel" : "Ready")
//                        .animation(nil, value: player.isReady)
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
