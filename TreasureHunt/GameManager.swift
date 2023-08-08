//
//  GameManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation

enum GameState {
    case notStart, start, end
}

class GameManager {
    static let instance = GameManager()
    @Published var treasuresFound: Int = 0
    @Published var gameState: GameState = .notStart
    let treasureAmount = 5

    func startGame() {
        //TODO: ADD FUNCTIONALITY TO START THE GAME
    }

    func endGame() {
        //TODO: ADD FUNCTIONALITY TO END GAME
        resetGame()
    }

    private func resetGame() {
        //TODO: ADD FUNCTIONALITY TO RESET GAME
    }
}

extension GameManager {
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        treasuresFound += 1
    }
}
