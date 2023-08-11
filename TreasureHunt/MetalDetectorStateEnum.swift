//
//  MetalDetectorState.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation

enum MetalDetectorState: String {
    case notDetected, far, close

    var soundManager: SoundManager {
        return SoundManager.instance
    }

    // TODO: Implement metal detector sound
    func playSound() {
        switch self {
        case .notDetected:
            soundManager.playSound(sound: .far, numberOfLoops: -1 )
            break
        case .far:
            soundManager.playSound(sound: .far, numberOfLoops: -1)
            break
        case .close:
            soundManager.playSound(sound: .close, numberOfLoops: -1)
            break
        }
    }
}
