//
//  UIApplicationExt.swift
//  TreasureHunt
//
//  Created by Kevin Sander Utomo on 21/08/23.
//

import Foundation
import SwiftUI

extension UIApplication {
    /*
     It will dismiss the keyboard
     */
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

