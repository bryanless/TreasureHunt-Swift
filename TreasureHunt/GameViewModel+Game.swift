//
//  GameViewModel+Game.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation

extension GameViewModel {
    func increaseFoundTreasure() {
        gameManager?.increaseFound()
    }

    func startGame() {
        futureDate = Calendar.current.date(byAdding: .second, value: 4, to: .now) ?? .now
        startTimer()
        gameManager.startGame()
        locationManager.startUpdatingLocation()
    }

    func endGame() {
        gameManager?.endGame()
        stopTimer()
        locationManager.stopLocation()
    }

    func resetGame() {
        gameManager?.resetGame()
    }

    private func updateTimer() {
        guard let futureDate else { return }
        let remaining = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: .now, to: futureDate)
        timeRemaining = remaining
    }

    private func startTimer() {
        self.updateTimer()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }

    private func stopTimer() {
        timeRemaining = nil
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}
