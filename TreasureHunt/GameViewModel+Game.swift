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
        futureDate = Calendar.current.date(byAdding: .minute, value: 3, to: .now) ?? .now
        startTimer()
        locationManager.startUpdatingLocation()
    }

    func endGame() {
        // TODO: End Multipeer Session
        gameManager?.endGame()
        stopTimer()
        locationManager.stopLocation()
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

    private func startTimer() {
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

    func loadEntityAsync (
        fileName: String,
        fileExtension: String,
        completion: @escaping (Result<Entity, Error>) -> Void
    ) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else { return }

        // Add URL Path from Bundle
        let url = URL(filePath: path)

        let loadRequest = Entity.loadAsync(contentsOf: url)

        loadRequest
            .sink(receiveCompletion: { loadCompletion in
                if case let .failure(error) = loadCompletion {
                    completion(.failure(error))
                }
            }, receiveValue: { entity in
                completion(.success(entity))
            })
            .store(in: &cancellables)
    }
}
