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
    @Published var gameData: GameData

    init() {
        gameData = GameData.gameDataInstance()
    }

    func startGame() {
        gameData.gameState = .start
        //TODO: ADD FUNCTIONALITY TO START THE GAME
    }

    func endGame() {
        gameData.gameState = .notStart
        //TODO: ADD FUNCTIONALITY TO END GAME
    }
}

extension GameManager {
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        gameData.treasuresFound += 1
    }
}
