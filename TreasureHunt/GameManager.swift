//
//  GameManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation
import MultipeerConnectivity

enum GameState: Codable {
    case notStart, start, end
}

//CONFORM TO NSOBJECT
class GameManager: NSObject {
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    private let serviceType: String = "treasure-hunt"
    private var peerID: MCPeerID!
    @Published var gameData: GameData
    @Published var isAdvertiser: Bool = false
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    private let peerJoinedHandler: (MCPeerID) -> Void
    private let peerLeftHandler: (MCPeerID) -> Void
    private let peerDiscoveredHandler: (MCPeerID) -> Bool
    
    
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void,
         peerJoinedHandler: @escaping (MCPeerID) -> Void,
         peerLeftHandler: @escaping (MCPeerID) -> Void,
         peerDiscoveredHandler: @escaping (MCPeerID) -> Bool) {
        self.receivedDataHandler = receivedDataHandler
        self.peerJoinedHandler = peerJoinedHandler
        self.peerLeftHandler = peerLeftHandler
        self.peerDiscoveredHandler = peerDiscoveredHandler
        gameData = GameData.gameDataInstance()
        super.init()
        setupMultipeer()
    }

//    init() {
//        gameData = GameData.gameDataInstance()
//    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    
    private func setupMultipeer() {
        let peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        isAdvertiser = true
    }
    
    func sendToPeersGameData(data: GameData) {
        if !session.connectedPeers.isEmpty {
            debugPrint("sendData: \(String(describing: data)) to \(self.session.connectedPeers[0].displayName)")
            do {
                let gameData = try JSONEncoder().encode(data)
                try session.send(gameData, toPeers: session.connectedPeers, with: .reliable)
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
    
    func increaseFound() {
        //TODO: ADD FUNCTIONALITY TO INCREASE SCORE WHEN USER FINDS TREASURE
        gameData.treasuresFound += 1
        //sendToPeersGameData(data: gameData)
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
}


extension GameManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            peerJoinedHandler(peerID)
        } else if state == .notConnected {
            peerLeftHandler(peerID)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data, peerID)
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
        debugPrint("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let accepted = peerDiscoveredHandler(peerID)
        if accepted {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        debugPrint("ServiceBrowser lost peer: \(peerID)")
    }
}

extension GameManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //TODO: Inform the user something went wrong and try again
        debugPrint("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}


