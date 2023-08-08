//
//  GameManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation

enum GameState {
    case notStart, start
}

class GameManager {
    static let instance = GameManager()
    @Published var treasuresFound: Int = 0
    @Published var gameState: GameState = .notStart
    let treasureAmount = 5

    func startGame() {
        gameState = .start
        treasuresFound = 0
        //TODO: ADD FUNCTIONALITY TO START THE GAME
    }

    func endGame() {
        gameState = .notStart
        //TODO: ADD FUNCTIONALITY TO END GAME
    }
}

extension GameManager {
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        treasuresFound += 1
    }
}
