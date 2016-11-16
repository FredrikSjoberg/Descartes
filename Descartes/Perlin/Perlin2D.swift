//
//  Perlin2D.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import GLKit

public struct Perlin2D {
    fileprivate let octaves: Int
    fileprivate let frequency: Float
    fileprivate let amplitude: Float
    fileprivate let seed: Int
    
    internal var p: [Int] = Array(repeating: 0, count: doubleBplus2)
    internal var g2: [CGPoint] = Array(repeating: CGPoint.zero, count: doubleBplus2)
    
    public init(octaves: Int, frequency: Float, amplitude: Float, seed: Int) {
        self.octaves = octaves
        self.frequency = frequency
        self.amplitude = amplitude
        self.seed = seed
        
        srand48(seed)
        
        for i in 0..<B {
            p[i] = i
            g2[i] = CGPoint(x: generateRandom, y: generateRandom).normalized
        }
        
        for i in (0..<B).reversed() {
            let j = Int(arc4random()) % B
            guard i != j else { continue }
            swap(&p[i], &p[j])
        }
        
        for i in 0..<B+2 {
            p[B+i] = p[i]
            g2[B+i] = g2[i]
        }
    }
}

public extension Perlin2D {
    public func noise(for point: CGPoint) -> Float {
        var amp = amplitude
        var vec = point*frequency
        var result: Float = 0
        for _ in 0..<octaves {
            result += generate2DNoise(for: vec)*amp
            vec = vec*2
            amp *= 0.5
        }
        return result
    }
    
    public func noise(for vector: GLKVector2) -> Float {
        return noise(for: vector.cgPoint)
    }
    
    /// Returns a value between [0, 1] regardless of the amplitude used
    public func normalizedNoise(for point: CGPoint) -> Float {
        return (noise(for: point) + amplitude)/(2*amplitude)
    }
    
    /// Returns a value between [0, 1] regardless of the amplitude used
    public func normalizedNoise(for vector: GLKVector2) -> Float {
        return normalizedNoise(for: vector.cgPoint)
    }
}

private extension Perlin2D {
    func generate2DNoise(for vec: CGPoint) -> Float {
        let x = Table(value: Float(vec.x))
        let y = Table(value: Float(vec.y))
        
        let i = p[x.b0]
        let j = p[x.b1]
        
        let m = Matrix(m00: p[i+y.b0], m10: p[j+y.b0], m01: p[i+y.b1], m11: p[j+y.b1])
        
        let sx = x.r0.sCurve
        let sy = y.r0.sCurve
        
        // u = xr0 * g2[m.m00].x ,yr0 * g2[m.m00].y
        // v = xr1 * g2[m.m10].x ,yr0 * g2[m.m10].y
        let a = sx.lerp(a: at2(g2[m.m00], x.r0, y.r0), b: at2(g2[m.m10], x.r1, y.r0))
        
        // u = xr0 * g2[m.m01].x ,yr1 * g2[m.m01].y
        // v = xr1 * g2[m.m11].x ,yr1 * g2[m.m11].y
        let b = sx.lerp(a: at2(g2[m.m01], x.r0, y.r1), b: at2(g2[m.m11], x.r1, y.r1))
        
        return sy.lerp(a: a, b: b)
    }
    
    func at2(_ point: CGPoint, _ rx: Float, _ ry: Float) -> Float {
        return (rx * Float(point.x) + ry * Float(point.y))
    }
}
