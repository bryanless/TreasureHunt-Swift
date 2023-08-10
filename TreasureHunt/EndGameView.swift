//
//  EndGameView.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 10/08/23.
//

import SwiftUI

struct EndGameView: View {
    @EnvironmentObject var gameVM: GameViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("DONE") {
            gameVM.resetGame()
        }
    }
}

struct EndGameView_Previews: PreviewProvider {
    static var previews: some View {
        EndGameView()
    }
}
