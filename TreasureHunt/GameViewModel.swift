//
//  ARViewModel.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 04/08/23.
//

import Foundation
import RealityKit
import CoreLocation
import Combine

class GameViewModel: ObservableObject {
    private let locationManager = LocationManager.instance
    let gameManager = GameManager.instance
    private var cancellables = Set<AnyCancellable>()
    var timerSubscription: AnyCancellable?
    var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    var futureDate: Date?
    @Published var timeRemaining: String?
    @Published var count: Int = 0
    @Published var treasuresFound: Int = 0
    @Published var gameState: GameState?
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var treasureDistance: CLLocationDistance?
    @Published var treasures: [Treasure] = []
    @Published var shouldSpawnTreasure: Bool = false
    @Published var messageText: String = ""
    @Published var metalDetectorState: MetalDetectorState = .notDetected

    init() {
        addSubscribers()
    }

    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let self, let currentLoc, let initialLoc else { return }
                self.currentLocation = currentLoc
                self.initialLocation = initialLoc
                self.messageText = self.checkLocationWithinCircularRegion(coordinate: initialLoc.coordinate) ?? "None"
                self.calculateDistances(currentLocation: currentLoc, treasures: self.treasures)
            }
            .store(in: &cancellables)

        locationManager.$initialLocation
            .removeDuplicates()
            .map(mapToTreasures)
            .sink { [weak self] returnedTreasures in
                self?.treasures = returnedTreasures
            }
            .store(in: &cancellables)

        $metalDetectorState
            .removeDuplicates()
            .sink { returnedState in
                returnedState.playSound()
            }
            .store(in: &cancellables)

        gameManager.$gameState
            .sink { [weak self] gameState in
                self?.gameState = gameState
            }
            .store(in: &cancellables)

        gameManager.$treasuresFound
            .sink { [weak self] foundTreasures in
                self?.treasuresFound = foundTreasures
            }
            .store(in: &cancellables)

        $gameState
            .combineLatest($timeRemaining)
            .sink { [weak self] state, remainingTime in
                if state == .notStart {
                    self?.startGame()
                } else if state == .start && remainingTime == "00:00" {
                    self?.endGame()
                }
            }
            .store(in: &cancellables)
    }
}
