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
        VStack {
            Text(showResultState() ?? "None")
            Text("Treasures Found")
            if let treasuresFound = gameVM.gameData?.treasuresFound {
                Text("\(treasuresFound)")
            }
            Button("DONE") {
                gameVM.resetGame()
            }
        }
    }
}

struct EndGameView_Previews: PreviewProvider {
    static var previews: some View {
        EndGameView()
    }
}

extension EndGameView {
    private func showResultState() -> String? {
        guard let gameData = gameVM.gameData else { return nil }
        switch gameData.treasuresFound {
        case 5:
            return "Superb"
        case 3...4:
            return "Cool"
        case 0...2:
            return "Better Luck Next Time"
        default:
            return "None"
        }
    }
}
