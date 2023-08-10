//
//  DateComponentsExt.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 10/08/23.
//

import Foundation

extension DateComponents {
    var shortTimer: String {
        let minute = String(format: "%02d", self.minute ?? 0)
        let second = String(format: "%02d", self.second ?? 0)
        return "\(minute):\(second)"
    }
}
