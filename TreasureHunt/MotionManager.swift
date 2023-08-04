//
//  MotionManager.swift
//  TreasureHunt
//
//  Created by Kenny Jinhiro Wibowo on 04/08/23.
//

import CoreMotion

class MotionManager: ObservableObject{
    //Instantiate CMMotionManager
    private let motionManager = CMMotionManager()
    
    //Add Properties of MotionManager
    @Published var x = 0.0
    @Published var y = 0.0
    
    init(){
        motionManager.startDeviceMotionUpdates(to: .main){ [weak self] data, error in
            guard let motion = data?.attitude else {return}
            self?.x = motion.roll
            self?.y = motion.pitch
        }
    }
}

