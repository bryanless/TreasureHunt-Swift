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
        }
        .onDisappear {
            revokeRoomSession()
        }
    }
}

//struct RoomCreatedView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomCreatedView(gameVM: GameViewModel(), multipeer: MultipeerManager())
//    }
//}

extension RoomCreatedView {
    private func revokeRoomSession() {
        if ((gameVM.gameManager?.isHost) == true) {
            print("Here")
            gameVM.gameManager?.stopAdvertising()
            gameVM.gameManager?.isHost = false
        }
        gameVM.gameManager?.gameData = GameData.dataInstance()
        gameVM.gameManager?.session.disconnect()
        gameVM.gameManager?.startBrowsing()
    }
}
