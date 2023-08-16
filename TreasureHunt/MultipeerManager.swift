import Foundation
import ARKit
import MultipeerConnectivity
import Combine

enum GameState: Codable {
    case notStart, start, end
}

class GameManager: NSObject {
    var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var currentPeerID: MCPeerID
    var browser: MCNearbyServiceBrowser
    private let serviceType: String = "TreasureHunt"
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    private let peerJoinedHandler: (MCPeerID) -> Void
    private let peerLeftHandler: (MCPeerID) -> Void
    private let peerDiscoveredHandler: (MCPeerID) -> Bool
    
    @Published var gameData: GameData
    @Published var currentPeer: Player
    @Published var isHost: Bool = false
    @Published var availablePlayers: [Player] = []
    @Published var availablePeers: [Peer] = []
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void,
         peerJoinedHandler: @escaping (MCPeerID) -> Void,
         peerLeftHandler: @escaping (MCPeerID) -> Void,
         peerDiscoveredHandler: @escaping (MCPeerID) -> Bool) {
        self.receivedDataHandler = receivedDataHandler
        self.peerJoinedHandler = peerJoinedHandler
        self.peerLeftHandler = peerLeftHandler
        self.peerDiscoveredHandler = peerDiscoveredHandler
        gameData = GameData.dataInstance()
        let peerID = MCPeerID(displayName: "\(UIDevice.current.name)")
        currentPeerID = peerID
        currentPeer = Player(id: UUID(), peerName: peerID.displayName, displayName: peerID.displayName)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
        startBrowsing()
    }
    
    deinit {
        advertiser.delegate = nil
        browser.delegate = nil
        stopAdvertising()
        stopBrowsing()
        session.disconnect()
    }
    
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        gameData.treasuresFound += 1
        sendToPeersGameData(data: gameData)
    }
    
    func startGame() {
        gameData.gameState = .start
        //sendToPeersGameData(data: gameData)
    }
    
    func endGame() {
        gameData.gameState = .end
        //sendToPeersGameData(data: gameData)
    }
    
    func resetGame() {
        gameData.gameState = .notStart
        //sendToPeersGameData(data: gameData)
    }
    
    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: currentPeerID,
                                               discoveryInfo: ["partyID": "\(gameData.id)", "name": currentPeerID.displayName  ], serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        isHost = true
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    func sendToPeersGameData(data: GameData) {
        if !session.connectedPeers.isEmpty {
            do {
                let game = try JSONEncoder().encode(data)
                if session.connectedPeers.count > 0 {
                    print("gameData sent")
                    print(data.joinedPlayers.count)
                    try session.send(game, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch let error {
                print("error sending data to peers \(session.connectedPeers): \(error.localizedDescription)")
            }
        }
    }
    
    func sendToPeersARData(data: Data) {
        if !session.connectedPeers.isEmpty {
            debugPrint("sendData: \(String(describing: data)) to \(self.session.connectedPeers[0].displayName)")
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                print("error sending data to peers \(session.connectedPeers): \(error.localizedDescription)")
            }
        }
    }
}


extension GameManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        if state == .connected {
            if isHost {
                self.gameData.joinedPlayers.append(Player(id: UUID(), peerName: peerID.displayName, displayName: peerID.displayName))
                print("From Manager: \(gameData.joinedPlayers)")
                sendToPeersGameData(data: self.gameData)
            }
            stopBrowsing()
            peerJoinedHandler(peerID)
        } else if state == .notConnected {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                for (index, player) in self.gameData.joinedPlayers.enumerated() {
                    if player.displayName == peerID.displayName {
                        self.gameData.joinedPlayers.remove(at: index)
                        //                        self.sendToPeersGameData(data: self.gameData)
                        break
                    }
                }
            }
            peerLeftHandler(peerID)
            startBrowsing()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //Data handler for AR
        receivedDataHandler(data, peerID)
        //Data handler for GameData
        print("Received Data from \(peerID.displayName)")
        DispatchQueue.main.async { [weak self] in
            do {
                self?.gameData = try JSONDecoder().decode(GameData.self, from: data)
                print("Decoded Data: \(self?.gameData)")
            } catch let error {
                print("Error decoding: \(error)")
            }
        }
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        debugPrint("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        debugPrint("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        debugPrint("This service does not send/receive streams.")
    }
}

extension GameManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        debugPrint("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for peer in self.availablePeers {
                if peer.peerId == peerID {
                    return
                }
            }
            
            guard let info else { return }
            self.availablePeers.append(Peer(partyId: UUID(uuidString: info["partyID"] ?? "")!, peerId: peerID))
        }
        
        guard let info else { return }
        print("PartyID: \(gameData.id)")
        print("UUID: \(UUID(uuidString: info["partyID"] ?? "")!)")
        
        if gameData.id == UUID(uuidString: info["partyID"] ?? "")! {
            print("PartyIW: \(gameData.id)")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            self?.availablePeers.removeAll { peer in
                return peer.peerId == peerID
            }
        }
    }
}

extension GameManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        debugPrint("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        DispatchQueue.main.async { [weak self] in
            invitationHandler(true, self?.session)
        }
    }
}
