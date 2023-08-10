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
    @Published var gameData: GameData
    
    init() {
        gameData = GameData.gameDataInstance()
    }
    
    func startGame() {
        gameData.gameState = .start
        //TODO: ADD FUNCTIONALITY TO START THE GAME
    }
    
    func endGame() {
        gameData.gameState = .end
        //TODO: ADD FUNCTIONALITY TO END GAME
    }

    func resetGame() {
        gameData.gameState = .notStart
    }

}

extension GameManager {
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        gameData.treasuresFound += 1
    }
}
