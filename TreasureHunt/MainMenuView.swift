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
            VStack {
                Text("Play Game")
                    .onTapGesture {
                        gameVM.startGame()
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
