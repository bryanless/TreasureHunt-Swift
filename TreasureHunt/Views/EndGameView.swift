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
        ZStack{
            Image("background-main-menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("end-game-title")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Phone.screenSize * 1.1)
                    .edgesIgnoringSafeArea(.all)
                Spacer()
                Image(showResultState() ?? "-")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Phone.screenSize * 1)
                    .offset(y: -24)
//                Text("Treasures Found")
//                if let treasuresFound = gameVM.gameData?.treasuresFound {
//                    Text("\(treasuresFound)")
//                }
                Spacer()
                Button {
                    gameVM.resetGame()
                } label: {
                    Image("back-to-main-menu-board")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Phone.screenSize * 1.2)
                }
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
        case 3:
            return "best-score"
        case 1...2:
            return "okay-score"
        case 0:
            return "least-score"
        default:
            return "None"
        }
    }
}
