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
    var cancellables = Set<AnyCancellable>()
    var timerSubscription: AnyCancellable?
    var futureDate: Date?
    var peerSessionIDs = [MCPeerID: String]()
    @Published var treasures: [Treasure] = []
    
    @Published var arView: GameARView?
    @Published var timeRemaining: DateComponents?
    @Published var gameManager: GameManager?

    @Published var isStarted: Bool = false
    @Published var gameState: GameState?
    @Published var gameData: GameData?
    @Published var currentLocation: CLLocation?
    @Published var initialLocation: CLLocation?
    @Published var treasureDistance: CLLocationDistance?
    @Published var shouldSpawnTreasure: Bool = false
    @Published var messageText: Bool?
    @Published var sessionIDObservation: NSKeyValueObservation?
    @Published var metalDetectorState: MetalDetectorState = .none

    @Published var currentPeer: Player?
    @Published var isHost: Bool = false
    @Published var availablePeers: [Peer] = []
    @Published var allPlayerReady: Bool = false
    @Published var countdownStart: Bool = false
    @Published var readyCountdown: Int = 5

    init() {
        gameManager = GameManager(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
        addSubscribers()
        multiPeerSubscribers()
    }

    func reset() {
        gameManager = GameManager(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
        addSubscribers()
        multiPeerSubscribers()
    }
    
    func setupARConfiguration() {
        arView = GameARView(onTreasureTap: increaseFoundTreasure)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.isCollaborationEnabled = true
        arView?.session.run(config)
        sessionIDObservation = arView?.session.observe(\.identifier, options: [.new]) { [weak self] object, change in
            print("SessionID changed to: \(change.newValue!)")
            guard let multipeerSession = self?.gameManager else { return }
            self?.sendARSessionIDTo(peers: multipeerSession.availablePeers.map({ peer in
                return peer.peerId!
            }))
        }
    }
    
    private func addSubscribers() {
        locationManager.$location
            .combineLatest(locationManager.$initialLocation)
            .sink { [weak self] currentLoc, initialLoc in
                guard let self, let currentLoc, let initialLoc else { return }
                self.currentLocation = currentLoc
                self.initialLocation = initialLoc
                self.messageText = self.checkLocationWithinCircularRegion(coordinate: initialLoc.coordinate) ?? false
                self.calculateDistances(currentLocation: currentLoc, treasures: self.treasures)
            }
            .store(in: &cancellables)
        
        locationManager.$initialLocation
            .removeDuplicates()
            .map(mapToTreasures)
            .sink { [weak self] returnedTreasures in
                self?.treasures = returnedTreasures
                print("TreasureCount", returnedTreasures.count)
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
                DispatchQueue.main.async {
                    self?.gameData = gameData
                    self?.gameState = gameData.gameState
                }
            }
            .store(in: &cancellables)

        gameManager?.$currentPeer
            .sink { [weak self] currentPeer in
                self?.currentPeer = currentPeer
            }
            .store(in: &cancellables)

        $gameData
            .combineLatest($currentPeer, $treasures)
            .sink { [weak self] gameData, currentPeer, treasure in
                guard let gameData, let currentPeer else { return }
                self?.handlePartyState(gameData: gameData, currentPeer: currentPeer)
                self?.changeStateGameLoaded(gameData: gameData, currentPeer: currentPeer, treasuresCount: treasure.count)
            }
            .store(in: &cancellables)
        
        $gameState
            .combineLatest($timeRemaining, $currentPeer, $gameData)
            .sink { [weak self] state, time, peer, data in
                guard let second = time?.second, let nano = time?.nanosecond else { return }
                if state == .start && second == 0 && nano < 0 {
                    self?.endGame()
                } else if state == .start && data?.treasuresFound == 3 {
                    self?.endGame()
                }
            }
            .store(in: &cancellables)
    }
    
    func multiPeerSubscribers() {
        gameManager?.$availablePeers
            .sink(receiveValue: { [weak self] peers in
                self?.availablePeers = peers
            })
            .store(in: &cancellables)
    }
}
