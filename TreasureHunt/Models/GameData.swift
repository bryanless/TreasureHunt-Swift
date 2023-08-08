//
//  GameData.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation

struct GameData {
    var treasuresFound: Int
    var gameState: GameState
    let treasureAmount: Int

    static func gameDataInstance() -> GameData {
        return GameData(treasuresFound: 0, gameState: .notStart, treasureAmount: 5)
    }
}
