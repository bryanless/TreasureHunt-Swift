////
////  GameManager.swift
////  TreasureHunt
////
////  Created by Kevin Sander Utomo on 07/08/23.
////
//
//import Foundation
//
//enum GameState: Codable {
//    case notStart, start, end
//}
//
//class GameManager: NSObject {
//    static let instance = GameManager()
//    @Published var gameData: GameData
//    
//    init() {
//        gameData = GameData.gameDataInstance()
//    }
//    func increaseFound() {
//        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
//        gameData.treasuresFound += 1
//        //sendToPeersGameData(data: gameData)
//    }
//    
//    func startGame() {
//        gameData.gameState = .start
//        //sendToPeersGameData(data: gameData)
//    }
//    
//    func endGame() {
//        gameData.gameState = .end
//        //sendToPeersGameData(data: gameData)
//    }
//    
//    func resetGame() {
//        gameData.gameState = .notStart
//        //sendToPeersGameData(data: gameData)
//    }
//}
