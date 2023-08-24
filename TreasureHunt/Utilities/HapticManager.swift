//
//  HapticManager.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 24/08/23.
//

import Foundation
import SwiftUI

class HapticManager {
    static let instance = HapticManager()

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
