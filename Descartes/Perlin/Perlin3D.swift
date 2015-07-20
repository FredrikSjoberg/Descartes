//
//  Perlin3D.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

public struct Perlin3D {
    private let octaves: Int
    private let frequency: Float
    private let amplitude: Float
    private let seed: Int
    
    internal var p: [Int] = Array(count: doubleBplus2, repeatedValue: 0)
    internal var g3: [GLKVector3] = Array(count: doubleBplus2, repeatedValue: GLKVector3Make(0, 0, 0))
    
    public init(octaves: Int, frequency: Float, amplitude: Float, seed: Int) {
        self.octaves = octaves
        self.frequency = frequency
        self.amplitude = amplitude
        self.seed = seed
        
        //        srand48(seed)
        srand(UInt32(seed))
        
        for i in 0..<B {
            p[i] = i
            g3[i] = GLKVector3Normalize(GLKVector3Make(generateRandom, generateRandom, generateRandom))
        }
        
        for i in reverse(0..<B) {
            let j = Int(rand()) % B
            swap(&p[i], &p[j])
        }
        
        for i in 0..<B+2 {
            p[B+i] = p[i]
            g3[B+i] = g3[i]
        }
    }
}

public extension Perlin3D {
    public func noise(vector: GLKVector3) -> Float {
        var amp = amplitude
        var vec = GLKVector3MultiplyScalar(vector, frequency)
        var result: Float = 0
        for i in 0..<octaves {
            result += generate3DNoise(vec)*amp
            vec = GLKVector3MultiplyScalar(vec, 2)
            amp *= 0.5
        }
        return result
    }
    
    public func noise(vector: SCNVector3) -> Float {
        return noise(SCNVector3ToGLKVector3(vector))
    }
}

private extension Perlin3D {
    private func generate3DNoise(vec: GLKVector3) -> Float {
        let x = Table(value: vec.x)
        let y = Table(value: vec.y)
        let z = Table(value: vec.z)
        
        let i = p[x.b0]
        let j = p[x.b1]
        
        let m = Matrix(m00: p[i+y.b0], m10: p[j+y.b0], m01: p[i+y.b1], m11: p[j+y.b1])
        
        let t = x.r0.sCurve
        let sy = y.r0.sCurve
        let sz = z.r0.sCurve
        
        let a = t.lerp(a: at3(g3[m.m00+z.b0], x.r0, y.r0, z.r0), b: at3(g3[m.m10+z.b0], x.r1, y.r0, z.r0))
        let b = t.lerp(a: at3(g3[m.m01+z.b0], x.r0, y.r1, z.r0), b: at3(g3[m.m11+z.b0], x.r1, y.r1, z.r0))
        let q = sy.lerp(a: a, b: b)
        
        let c = t.lerp(a: at3(g3[m.m00+z.b1], x.r0, y.r0, z.r1), b: at3(g3[m.m10+z.b1], x.r1, y.r0, z.r1))
        let d = t.lerp(a: at3(g3[m.m01+z.b1], x.r0, y.r1, z.r1), b: at3(g3[m.m11+z.b1], x.r1, y.r1, z.r1))
        let r = sy.lerp(a: c, b: d)
        
        return sz.lerp(a: q, b: r)
    }
    
    private func at3(vector: GLKVector3, _ rx: Float, _ ry: Float, _ rz: Float) -> Float {
        return (rx * vector.x + ry * vector.y + rz * vector.z)
    }
}