//
//  MetalDetectorState.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation

enum MetalDetectorState: String {
    case notDetected, far, near, close

    var soundManager: SoundManager {
        return SoundManager.instance
    }

    // TODO: Implement metal detector sound
    func playSound() {
        switch self {
        case .notDetected:
            break
        case .far:
            soundManager.playSound(sound: .far)
            break
        case .near:
            soundManager.playSound(sound: .near)
            break
        case .close:
            soundManager.playSound(sound: .close)
            break
        }
    }
}
