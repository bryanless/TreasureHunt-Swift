//
//  GameData.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation
import MultipeerConnectivity

struct GameData: Codable, Identifiable, Equatable {
    static func == (lhs: GameData, rhs: GameData) -> Bool {
        return lhs.treasuresFound == rhs.treasuresFound && lhs.gameState == rhs.gameState && lhs.treasureAmount == rhs.treasureAmount && lhs.joinedPlayers == rhs.joinedPlayers
    }

    var id = UUID()
    var treasuresFound: Int
    var gameState: GameState
    let treasureAmount: Int
    var joinedPlayers: [Player] = []
//    var isGameStarted: Bool = false

    init(treasuresFound: Int, gameState: GameState, treasureAmount: Int) {
        self.treasuresFound = treasuresFound
        self.gameState = gameState
        self.treasureAmount = treasureAmount
    }

    enum CodingKeys: String, CodingKey {
        case id, treasuresFound, gameState, treasureAmount, joinedPlayers
    }

    static func dataInstance() -> GameData {
        return GameData(treasuresFound: 0, gameState: .notStart, treasureAmount: 5)
    }
}
