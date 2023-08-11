//
//  ARViewModel.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 04/08/23.
//

import Foundation
import ARKit
import CoreLocation
import MultipeerConnectivity
import Combine

class GameViewModel: ObservableObject {
    let locationManager = LocationManager.instance
    @Published var gameManager: GameManager?
    var cancellables = Set<AnyCancellable>()
    var timerSubscription: AnyCancellable?
    //    var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    var futureDate: Date?
    var peerSessionIDs = [MCPeerID: String]()
    @Published var arView: GameARView?
    @Published var timeRemaining: DateComponents?
    @Published var treasuresFound: Int?
    @Published var gameState: GameState?
    @Published var currentLocation: CLLocation?
    @Published var treasureDistance: CLLocationDistance?
    @Published var treasures: [Treasure] = []
    @Published var shouldSpawnTreasure: Bool = false
    @Published var messageText: String = ""
    @Published var sessionIDObservation: NSKeyValueObservation?
    @Published var metalDetectorState: MetalDetectorState = .notDetected

    init() {
        setupARConfiguration()
        gameManager = GameManager(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        addSubscribers()
    }

    private func setupARConfiguration() {
        arView = GameARView(onTreasureTap: increaseFoundTreasure)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.isCollaborationEnabled = true
        arView?.session.run(config)
        sessionIDObservation = arView?.session.observe(\.identifier, options: [.new]) { [weak self] object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self?.gameManager else { return }
            self?.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
    }

    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let self, let currentLoc, let initialLoc else { return }
                self.currentLocation = currentLoc
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

        gameManager?.$gameData
            .sink { [weak self] gameData in
                self?.gameState = gameData.gameState
                self?.treasuresFound = gameData.treasuresFound
            }
            .store(in: &cancellables)

        $gameState
            .combineLatest($timeRemaining)
            .sink { [weak self] state, time in
                guard let second = time?.second, let nano = time?.nanosecond else { return }
                print("\(second) \(nano)")
                if state == .start && second == 0 && nano < 0 {
                    self?.endGame()
                }
            }
            .store(in: &cancellables)
    }
}
