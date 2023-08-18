//
//  LobbyView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 13/08/23.
//

import SwiftUI

struct LobbyView: View {
    //    gameVM.gameManager?.startGame()

    @EnvironmentObject var gameVM: GameViewModel
    @State private var navigateToRoom = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pick Room")
                List {
                    ForEach(gameVM.availablePeers, id: \.self) { peer in
                        Text(peer.peerId?.displayName ?? "None")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectRoom(currentPeer: peer)
                            }
                    }
                }

                Text("Create Room")
                    .font(.headline)
                    .onTapGesture {
                        createRoom()
                    }
            }
            .background(
                NavigationLink(destination: RoomCreatedView(), isActive: $navigateToRoom, label: {
                    EmptyView()
                })
            )
        }
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView()
    }
}

extension LobbyView {
    private func createRoom() {
        guard let gameManager = gameVM.gameManager else { return }
        gameManager.gameData = GameData.dataInstance()
        gameManager.currentPeer.isHost = true
        gameManager.gameData.joinedPlayers.append(gameManager.currentPeer)
        gameManager.startAdvertising()
        navigateToRoom = true
    }

    private func selectRoom(currentPeer: Peer) {
        //TODO: Handle isStarted game joining here
        gameVM.gameManager?.gameData.id = currentPeer.partyId
        gameVM.gameManager?.stopBrowsing()
        gameVM.gameManager?.startBrowsing()
        navigateToRoom = true
    }
}
