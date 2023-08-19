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
            VStack {
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
                    .padding(.leading, 15)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack {
                    Text("Current Players")
//                    List {
                    ScrollView{
                        ForEach((gameVM.gameManager?.gameData.joinedPlayers)!, id: \.self) { player in
                            ZStack {
                                Image("board")
                                    .resizable()
                                    .scaledToFit()
                                HStack {
                                    Spacer()
                                    Text(player.peerName)
                                    Spacer()
                                    Image(systemName: "crown")
                                        .opacity(player.isHost ? 1 : 0)
                                    Image(systemName: player.isReady ? "checkmark" : "xmark")
                                        .foregroundColor(player.isReady ? .green : .red)
                                    Spacer()
                                }.offset(y: -2)
                            }.frame(width: 400, alignment: .leading)
                        }
                        readyButton
                    }
                }
                if gameVM.countdownStart {
                    VStack {
                        Text("Countdown in \(gameVM.readyCountdown)")
                    }
                } else {
                    VStack {
                        Text("Waiting for all players to ready up!")
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
                    Text(player.isReady ? "Cancel" : "Ready")
                        .animation(nil, value: player.isReady)
                }
            }
        }
    }
    private func revokeRoomSession() {
        if ((gameVM.gameManager?.isHost) == true) {
            gameVM.gameManager?.stopAdvertising()
            gameVM.gameManager?.isHost = false
        }
        gameVM.gameManager?.gameData = GameData.dataInstance()
        gameVM.gameManager?.session.disconnect()
        gameVM.gameManager?.startBrowsing()
    }
}
