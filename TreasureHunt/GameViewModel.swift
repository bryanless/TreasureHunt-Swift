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
    var treasures: [Treasure] = []
    
    @Published var arView: GameARView?
    @Published var timeRemaining: DateComponents?
    @Published var gameManager: GameManager?
    
    
    //    @Published var treasuresFound: Int?
    @Published var gameState: GameState?
    @Published var gameData: GameData?
    @Published var currentLocation: CLLocation?
    @Published var treasureDistance: CLLocationDistance?
    @Published var shouldSpawnTreasure: Bool = false
    @Published var messageText: String = ""
    @Published var sessionIDObservation: NSKeyValueObservation?
    @Published var metalDetectorState: MetalDetectorState = .notDetected
    @Published var currentPeer: Player?
    @Published var isHost: Bool = false
    @Published var availablePeers: [Peer] = []
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    init() {
        setupARConfiguration()
        gameManager = GameManager(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
        addSubscribers()
        multiPeerSubscribers()
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
            .combineLatest(gameManager!.$currentPeer)
            .sink { [weak self] gameData, currentPeer in
                print("Received gameData: \(gameData.id)")
                self?.gameData = gameData
                self?.gameState = gameData.gameState
                self?.currentPeer = currentPeer
                self?.handlePartyState(gameData: gameData, currentPeer: currentPeer)
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
    
    func multiPeerSubscribers() {
        gameManager?.$availablePeers
            .sink(receiveValue: { [weak self] peers in
                self?.availablePeers = peers
            })
            .store(in: &cancellables)
        
        gameManager?.$isHost
            .sink(receiveValue: { [weak self] host in
                self?.isHost = host
            })
            .store(in: &cancellables)
        
        gameManager?.$invitationHandler
            .sink(receiveValue: { [weak self] handler in
                self?.invitationHandler = handler
            })
            .store(in: &cancellables)
        
    }
}
