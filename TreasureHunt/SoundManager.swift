//
//  SoundManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 07/08/23.
//

import Foundation
import AVKit

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer? = nil

    func playSound(sound: MetalDetectorState) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let e {
            print("Error playing sound. \(e.localizedDescription)")
        }
    }
}
