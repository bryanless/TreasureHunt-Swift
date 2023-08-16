//
//  RoomCreatedView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 13/08/23.
//

import SwiftUI

struct RoomCreatedView: View {
    @EnvironmentObject var gameVM: GameViewModel
    var body: some View {
        
        VStack {
            VStack {
                Text("Current Players")
                List {
                    ForEach(gameVM.gameData!.joinedPlayers, id: \.self) { player in
                        HStack {
                            Text(player.displayName)
                            //.opacity((gameVM.currentPeer?.isHost ?? false) ? 1 : 0)
                        }
                    }
                }
                
                Text("Connected Browsers")
                if let session = gameVM.gameManager?.session {
                    List {
                        ForEach((session.connectedPeers), id: \.self) { player in
                            HStack {
                                Text(player.displayName)
                            }
                        }
                    }
                }
                Button("Start Game") {
                    gameVM.startGame()
                }
            }
//            .onChange(of: gameVM.gameManager?.gameData) { _ in
//                print("Hello")
//                guard let gameData = gameVM.gameData else { return }
//                if gameData.joinedPlayers.count > 0 {
//                    print("Enter joined here")
//                    var notInLobby = false
//                    for player in gameData.joinedPlayers {
//                        if player.displayName == gameVM.currentPeer?.displayName {
//                            notInLobby = true
//                            break
//                        }
//                    }
//                    if !notInLobby {
//                        guard let currentPeer = gameVM.currentPeer else { return }
//                        gameVM.gameData?.joinedPlayers.append(currentPeer)
//                        gameVM.gameManager?.sendToPeersGameData(data: gameData)
//                    }
//                }
//            }
        }
    }
}

//struct RoomCreatedView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomCreatedView(gameVM: GameViewModel(), multipeer: MultipeerManager())
//    }
//}
