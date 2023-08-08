//
//  GameViewModel+Game.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation

extension GameViewModel {
    private func increaseFoundTreasure() {
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
        let minute = remaining.minute ?? 0
        let second = remaining.second ?? 0
        let formattedMinute = String(format: "%02d", minute)
        let formattedSecond = String(format: "%02d", second)
        timeRemaining = "\(formattedMinute):\(formattedSecond)"
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
