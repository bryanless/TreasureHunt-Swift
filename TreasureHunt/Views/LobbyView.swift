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
    private var screenSize = UIScreen.main
    @Environment(\.dismiss) private var dismiss
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
                            Spacer()
                        }
                        VStack{
                            Spacer()
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
                        VStack(alignment: .leading) {
                            HStack {
                                Button{
                                    dismiss()
                                } label: {
                                    Image("back-button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Phone.screenSize * 0.15)
                                }
                                Spacer()
                            }.frame(width: Phone.screenSize * 0.95)
                            Spacer()
                        }.frame(width: Phone.screenSize * 0.95)
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
                        }.offset(y: 104)
                        VStack(alignment: .leading) {
                            HStack {
                                Button{
                                    dismiss()
                                } label: {
                                    Image("back-button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Phone.screenSize * 0.15)
                                }
                                Spacer()
                            }.frame(width: Phone.screenSize * 0.95)
                            Spacer()
                        }.frame(width: Phone.screenSize * 0.95)
                    }

                }
            }
        }
        .navigationBarBackButtonHidden()
        .background(
            NavigationLink(destination: RoomCreatedView( navigateToRoom: $navigateToRoom), isActive: $navigateToRoom, label: {
                EmptyView()
            })
        )
    }
}

struct LobbyView_Previews: PreviewProvider {
    static var previews: some View {
        LobbyView()
    }
}

extension LobbyView {

    private var lobbyScreen: some View {
        ZStack {
            Image("background-main-menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            Image("lobby-title")
                .resizable()
                .scaledToFit()
                .frame(width: 480)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack {
                    ForEach(gameVM.availablePeers, id: \.self) { peer in
                        ZStack {
                            Image("board")
                                .resizable()
                                .scaledToFit()
                            Text(peer.name)
                                .font(.custom("FingerPaint-Regular", size: 16))
                                .offset(y: -2)
                        }
                        .onTapGesture {
                            selectRoom(currentPeer: peer)
                        }
                        .frame(width: 352, alignment: .leading)
                    }

                    Button {
                        createRoom()
                    } label: {
                        Image("create-room-board")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 360)
                    }
                }
                .frame(maxWidth: .infinity)
                .offset(y: 120)
            }

            VStack {
                Spacer()

                Text("Change Name")
                    .font(.custom("FingerPaint-Regular", size: 16))
                    .padding(.bottom, 20)
                    .onTapGesture {
                        withAnimation {
                            gameVM.gameManager?.currentPeer.peerName = ""
                        }
                    }
            }
        }
        .transition(AnyTransition.opacity.animation(.easeInOut))
    }
    
    private var enterNameScreen: some View {
        ZStack {
            Image("background-main-menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack{
                Image("username-board")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 480)
                    .edgesIgnoringSafeArea(.all)
                    .offset(y: -4)
                ZStack{
                    Image("username-textfield")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 480)
                    HStack{
                        Spacer()
                        TextField("Enter Name here!", text: $setName)
                            .frame(width: 320)
                            .font(.custom("FingerPaint-Regular", size: 24))
                        Spacer()
                    }
                }
                Spacer()
                Button {
                    withAnimation {
                        gameVM.gameManager?.currentPeer.peerName = setName
                        UIApplication.shared.endEditing()
                    }
                } label: {
                    Image("username-enter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360)
                }
            }
        }
        .transition(AnyTransition.opacity.animation(.easeInOut))
    }
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
