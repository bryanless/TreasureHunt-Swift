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
    private init() {}

    func playSound(sound: MetalDetectorState, numberOfLoops: Int = 0) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            stopSound()
            player?.numberOfLoops = numberOfLoops
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }

    func stopSound() {
        player?.stop()
    }
}
