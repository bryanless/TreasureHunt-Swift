//
//  Float4x4+Ext.swift
//  TreasureHunt
//
//  Created by Bryan on 20/08/23.
//

import simd

extension SIMD4 where Scalar == Float {

    init(_ xyz: SIMD3<Float>, _ w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }

    var xyz: SIMD3<Float> {
        get { return SIMD3<Float>(x: x, y: y, z: z) }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}

extension float4x4 {
    var forward: SIMD3<Float> {
        normalize(SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z))
    }

    init(translation: SIMD3<Float>) {
        self.init(columns: (SIMD4<Float>(1, 0, 0, 0),
                            SIMD4<Float>(0, 1, 0, 0),
                            SIMD4<Float>(0, 0, 1, 0),
                            SIMD4<Float>(translation.x, translation.y, translation.z, 1)))
    }

    var translation: SIMD3<Float> {
        get {
            return columns.3.xyz
        }
        set {
            columns.3.xyz = newValue
        }
    }
}
