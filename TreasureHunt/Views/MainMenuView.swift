//
//  MainMenuView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 10/08/23.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameVM: GameViewModel
    var body: some View {
        NavigationStack {
            ZStack{
                Image("background-main-menu")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                Image("circle-main-menu")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 360)
                Image("board-main-menu")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 360)
                NavigationLink {
                    LobbyView()
                } label: {
                    Image("menu-main-menu")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 480)
                }

            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
