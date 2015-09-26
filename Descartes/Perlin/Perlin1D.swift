//
//  Perlin1D.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation


public struct Perlin1D {
    private let octaves: Int
    private let frequency: Float
    private let amplitude: Float
    private let seed: Int
    
    internal var p: [Int] = Array(count: doubleBplus2, repeatedValue: 0)
    internal var g1: [Float] = Array(count: doubleBplus2, repeatedValue: 0)
    
    public init(octaves: Int, frequency: Float, amplitude: Float, seed: Int) {
        self.octaves = octaves
        self.frequency = frequency
        self.amplitude = amplitude
        self.seed = seed
        
        //        srand48(seed)
        srand(UInt32(seed))
        
        for i in 0..<B {
            p[i] = i
            g1[i] = generateRandom
        }
        
        for i in (0..<B).reverse() {
            let j = Int(rand()) % B
            swap(&p[i], &p[j])
        }
        
        for i in 0..<B+2 {
            p[B+i] = p[i]
            g1[B+i] = g1[i]
        }
    }
}

public extension Perlin1D {
    public func noise(value: Float) -> Float {
        var amp = amplitude
        var vec = value*frequency
        var result: Float = 0
        for _ in 0..<octaves {
            result += generate1DNoise(vec)*amp
            vec = vec*2
            amp *= 0.5
        }
        return result
    }
}

private extension Perlin1D {
    private func generate1DNoise(value: Float) -> Float {
        let t = Table(value: value)
        
        let sx = t.r0.sCurve
        
        let u = t.r0 * g1[p[t.b0]]
        let v = t.r1 * g1[p[t.b1]]
        
        return sx.lerp(a: u, b: v)
    }
}