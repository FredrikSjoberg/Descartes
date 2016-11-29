//
//  Perlin1D.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import GameplayKit

public struct Perlin1D {
    fileprivate let octaves: Int
    fileprivate let frequency: Float
    fileprivate let amplitude: Float
    fileprivate let seed: UInt64
    fileprivate let random: GKRandom
    
    internal var p: [Int] = Array(repeating: 0, count: doubleBplus2)
    internal var g1: [Float] = Array(repeating: 0, count: doubleBplus2)
    
    public init(octaves: Int, frequency: Float, amplitude: Float, seed: UInt64) {
        self.octaves = octaves
        self.frequency = frequency
        self.amplitude = amplitude
        self.seed = seed
        self.random = GKMersenneTwisterRandomSource(seed: seed)
        
        for i in 0..<B {
            p[i] = i
            g1[i] = generateRandom(random)
        }
        
        for i in (0..<B).reversed() {
            let j = random.nextInt(upperBound: Int.max) % B
            guard i != j else { continue }
            swap(&p[i], &p[j])
        }
        
        for i in 0..<B+2 {
            p[B+i] = p[i]
            g1[B+i] = g1[i]
        }
    }
}

public extension Perlin1D {
    public func noise(for value: Float) -> Float {
        var amp = amplitude
        var vec = value*frequency
        var result: Float = 0
        for _ in 0..<octaves {
            result += generate1DNoise(for: vec)*amp
            vec = vec*2
            amp *= 0.5
        }
        return result
    }
    
    /// Returns a value between [0, 1] regardless of the amplitude used
    public func normalizedNoise(for value: Float) -> Float {
        return (noise(for: value) + amplitude)/(2*amplitude)
    }
}

private extension Perlin1D {
    func generate1DNoise(for value: Float) -> Float {
        let t = Table(value: value)
        
        let sx = t.r0.sCurve
        
        let u = t.r0 * g1[p[t.b0]]
        let v = t.r1 * g1[p[t.b1]]
        
        return sx.lerp(a: u, b: v)
    }
}
