//
//  GameViewModel+Game.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation

extension GameViewModel {
    func increaseFoundTreasure() {
        gameManager.increaseFound()
    }

    func startGame() {
        futureDate = Calendar.current.date(byAdding: .second, value: 11, to: .now) ?? .now
        gameManager.startGame()
        startTimer()
    }

    func endGame() {
        gameManager.endGame()
        stopTimer()
        startGame()
    }

    private func updateTimer() {
        guard let futureDate else { return }
        let remaining = Calendar.current.dateComponents([.hour, .minute, .second], from: .now, to: futureDate)
        let minute = String(format: "%02d", remaining.minute ?? 0)
        let second = String(format: "%02d", remaining.second ?? 0)
        timeRemaining = "\(minute):\(second)"
    }

    private func startTimer() {
        timerSubscription = timer
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}
