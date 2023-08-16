//
//  Player.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 15/08/23.
//

import Foundation


struct Player: Codable, Equatable, Hashable {
    var id: UUID
    var peerName: String = ""
    var displayName: String
}
