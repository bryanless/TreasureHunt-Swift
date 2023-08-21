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
    var player: AVAudioPlayer?
    var timerPlayer: AVAudioPlayer?
    private init() {
        guard let url = Bundle.main.url(forResource: "clock_tick_sfx", withExtension: ".mp3") else { return }

        do {
            timerPlayer = try AVAudioPlayer(contentsOf: url)
            timerPlayer?.numberOfLoops = -1
            timerPlayer?.prepareToPlay()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }

    func playTimerSound() {
        guard !(timerPlayer?.isPlaying ?? false) else { return }

        timerPlayer?.play()
    }

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

    func stopTimerSound() {
        timerPlayer?.stop()
    }
}
