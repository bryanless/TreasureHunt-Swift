//
//  GameViewModel+ARMultipeer.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 11/08/23.
//
import SwiftUI
import Foundation
import RealityKit
import ARKit
import MultipeerConnectivity

extension GameViewModel {
    func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = gameManager else { return }
        let idString = arView?.session.identifier.uuidString ?? ""
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeersARData(data: commandData)
        }
    }
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView?.session.update(with: collaborationData)
            return
        }
        // ...
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                        offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            if let oldSessionID = peerSessionIDs[peer] {
                removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
            }
            
            peerSessionIDs[peer] = newSessionID
        }
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = gameManager else { return false }
        
        if multipeerSession.session.connectedPeers.count > 3 {
            // Do not accept more than four users in the experience.
            print("A fifth peer wants to join the experience.\nThis app is limited to 3 users.")
            return false
        } else {
            return true
        }
    }
    /// - Tag: PeerJoined
    func peerJoined(_ peer: MCPeerID) {
        print("""
            A peer wants to join the experience.
            Hold the phones next to each other.
            """)
        // Provide your session ID to the new user so they can keep track of your anchors.
        sendARSessionIDTo(peers: [peer])
    }
    
    func peerLeft(_ peer: MCPeerID) {
        print("A peer has left the shared experience.")
        
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = arView?.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                arView?.session.remove(anchor: anchor)
            }
        }
    }
    
    func handlePartyState(gameData: GameData, currentPeer: Player) {
        if gameData.joinedPlayers.count > 0 {
            var notInLobby = false
            for player in gameData.joinedPlayers {
                if player.id == currentPeer.id {
                    notInLobby = true
                    break
                }
            }
            if !notInLobby {
                gameManager?.gameData.joinedPlayers.append(currentPeer)
                gameManager?.sendToPeersGameData(data: gameData)
            }

            DispatchQueue.main.async { [weak self] in
                self?.allPlayerReady = gameData.joinedPlayers.allSatisfy { player in
                    return player.isReady
                }

                if self?.allPlayerReady == true {
                    self?.countdownStart = true
                } else {
                    self?.countdownStart = false
                    self?.readyCountdown = 5
                }
            }
        }
    }
}
