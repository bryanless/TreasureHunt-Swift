//
//  GameData.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation

struct GameData: Codable, Identifiable {
    var id: UUID = UUID()
    var treasuresFound: Int
    var gameState: GameState
    let treasureAmount: Int

    init(treasuresFound: Int, gameState: GameState, treasureAmount: Int) {
        self.treasuresFound = treasuresFound
        self.gameState = gameState
        self.treasureAmount = treasureAmount
    }

    enum CodingKeys: String, CodingKey {
        case id, treasuresFound, gameState, treasureAmount
    }

    static func gameDataInstance() -> GameData {
        return GameData(treasuresFound: 0, gameState: .notStart, treasureAmount: 5)
    }
}
