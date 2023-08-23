//
//  Player.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 15/08/23.
//

import Foundation

struct Player: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    let displayName: String
    var peerName: String = ""
    var isReady: Bool = false
    var isHost: Bool = false
    var isGameLoaded: Bool = false
}
