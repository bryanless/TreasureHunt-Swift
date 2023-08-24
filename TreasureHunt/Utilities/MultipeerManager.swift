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
    
    @Published var setName: String = ""
    @Published var gameData: GameData
    @Published var currentPeer: Player
    @Published var isHost: Bool = false
    @Published var availablePeers: [Peer] = []
    var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void,
         peerJoinedHandler: @escaping (MCPeerID) -> Void,
         peerLeftHandler: @escaping (MCPeerID) -> Void,
         peerDiscoveredHandler: @escaping (MCPeerID) -> Bool) {
        self.receivedDataHandler = receivedDataHandler
        self.peerJoinedHandler = peerJoinedHandler
        self.peerLeftHandler = peerLeftHandler
        self.peerDiscoveredHandler = peerDiscoveredHandler
        gameData = GameData.dataInstance()
        let peerID = MCPeerID(displayName: "\(UIDevice.current.name)-\(UUID().uuidString)")
        currentPeerID = peerID
        currentPeer = Player(id: UUID(), displayName: peerID.displayName, peerName: "")
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        startBrowsing()
    }
    
    deinit {
        advertiser.delegate = nil
        browser.delegate = nil
        stopAdvertising()
        stopBrowsing()
        session.disconnect()
    }

    func reset() {
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
        sendToPeersGameData(data: gameData)
    }
    
    func endGame() {
        gameData.gameState = .end
        sendToPeersGameData(data: gameData)
    }
    
    func resetGame() {
//        gameData.gameState = .notStart
        sendToPeersGameData(data: GameData.dataInstance())
    }
    
    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: currentPeerID,
                                               discoveryInfo: ["partyID": "\(gameData.id)",
                                                               "name": currentPeer.peerName], serviceType: serviceType)
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
                    try session.send(game, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch let error {
                print("error sending data to peers \(session.connectedPeers): \(error.localizedDescription)")
            }
        }
    }
    
    func sendToPeersARData(data: Data) {
        if !session.connectedPeers.isEmpty {
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
                sendToPeersGameData(data: gameData)
            }
            stopBrowsing()
            peerJoinedHandler(peerID)
        } else if state == .notConnected {
            DispatchQueue.main.async { [weak self] in

                guard let self,
                      self.gameData.joinedPlayers.contains(where: { $0.displayName == peerID.displayName }),
                      let index = self.gameData.joinedPlayers.firstIndex(where: { $0.displayName == peerID.displayName }) else { return }
                self.gameData.joinedPlayers.remove(at: index)
                sendToPeersGameData(data: self.gameData)
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
            guard let self, let info else { return }
            if !self.availablePeers.contains(where: { $0.peerId == peerID }) {
                self.availablePeers.append(Peer(name: info["name"]!, partyId: UUID(uuidString: info["partyID"] ?? "")!, peerId: peerID))
            } else {
                return
            }
        }
        
        if let info, gameData.id == UUID(uuidString: info["partyID"] ?? "") {
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
