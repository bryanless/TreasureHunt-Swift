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
    @State private var setName: String = ""
    @State private var navigateToRoom = false
    var body: some View {
        NavigationStack {
            VStack {
                if gameVM.currentPeer?.peerName == "" {
                    ZStack {
                        Image("background-main-menu")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        VStack{
                            Image("username-board")
                                .resizable()
                                .scaledToFit()
                                .frame(width: Phone.screenSize * 1.2)
                                .edgesIgnoringSafeArea(.all)
                                .offset(y: -4)
                            ZStack{
                                Image("username-textfield")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Phone.screenSize * 1.2)
                                HStack{
                                    Spacer()
                                    TextField("Enter Name here!", text: $setName)
                                        .frame(width: Phone.screenSize * 0.7)
                                        .font(.custom("FingerPaint-Regular", size: 24))
                                    Spacer()
                                }
                            }
                            Spacer()
                            Button {
                                gameVM.gameManager?.currentPeer.peerName = setName
                            } label: {
                                Image("username-enter")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Phone.screenSize * 1.2)
                            }
                        }
                    }
                } else {
                    ZStack {
                        Image("background-main-menu")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        //                            List {
                        Image("lobby-title")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Phone.screenSize * 1.2)
                            .edgesIgnoringSafeArea(.all)
                        ScrollView {
                            ForEach(gameVM.availablePeers, id: \.self) { peer in
                                ZStack {
                                    Image("board")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Phone.screenSize * 1)
                                    Text(peer.name)
                                        .font(.custom("FingerPaint-Regular", size: 16))
                                        .offset(y: -2)
                                }
                                .onTapGesture {
                                    selectRoom(currentPeer: peer)
                                }
                                .frame(width: 352, alignment: .leading)

                            }
                            VStack {
                                Button {
                                    createRoom()
                                } label: {
                                    Image("create-room-board")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Phone.screenSize * 1.2)
                                }
                            }
                        }.offset(y: 64)

                    }

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
        // Allow the player to join the room
        gameVM.gameManager?.gameData.id = currentPeer.partyId
        gameVM.gameManager?.stopBrowsing()
        gameVM.gameManager?.startBrowsing()
        navigateToRoom = true
    }

}
