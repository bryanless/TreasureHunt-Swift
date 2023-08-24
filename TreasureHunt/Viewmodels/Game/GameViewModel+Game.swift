//
//  GameViewModel+Game.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 08/08/23.
//

import Foundation
import RealityKit

extension GameViewModel {
    func increaseFoundTreasure() {
        gameManager?.increaseFound()
    }
    
    func startGame() {
        gameManager?.startGame()
        locationManager.startUpdatingLocation()
        setupARConfiguration()
    }
    
    func endGame() {
        // TODO: End Multipeer Session
        gameManager?.endGame()
        stopTimer()
        locationManager.stopLocation()
        metalDetectorState = .none
        //        gameManager?.reset()
    }
    
    func resetGame() {
        gameManager?.resetGame()
    }
    
    private func updateTimer() {
        guard let futureDate else { return }
        let remaining = Calendar.current.dateComponents(
            [.hour, .minute, .second, .nanosecond],
            from: .now,
            to: futureDate)
        timeRemaining = remaining
    }
    
    func startTimer() {
        futureDate = Calendar.current.date(byAdding: .minute, value: 5, to: .now) ?? .now
        SoundManager.instance.playTimerSound()
        self.updateTimer()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func stopTimer() {
        SoundManager.instance.stopTimerSound()
        timeRemaining = nil
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}
