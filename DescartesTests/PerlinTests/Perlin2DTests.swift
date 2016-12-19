//
//  Perlin2DTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import GLKit
@testable import Descartes

class Perlin2DTests: QuickSpec {
    override func spec(){
        let variance = 0.0001
        let points = [
            CGPoint.zero,
            CGPoint(x: 0.1, y: 0.1),
            CGPoint(x: 0.2, y: 0.3),
            CGPoint(x: 0.3, y: 0.6),
            CGPoint(x: 0.4, y: 0.9),
            CGPoint(x: 0.5, y: 0.8),
        ]
        
        let glkVector1 = GLKVector2(v: (0.6, 0.7))
        let glkVector2 = GLKVector2(v: (0.8, 0.5))
        
        describe("Deterministic") {
            it("should generate same results every time") {
                let perlin = Perlin2D(octaves: 4, frequency: 4, amplitude: 1, seed: 1)
                expect(perlin.noise(for: points[0])).to(beCloseTo(0, within: variance))
                expect(perlin.noise(for: points[1])).to(beCloseTo(0.0085, within: variance))
                expect(perlin.noise(for: points[2])).to(beCloseTo(-0.1113, within: variance))
                expect(perlin.normalizedNoise(for: points[2])).to(beCloseTo(0.4443, within: variance))
                expect(perlin.noise(for: points[3])).to(beCloseTo(0.1150, within: variance))
                expect(perlin.noise(for: points[4])).to(beCloseTo(0.0822, within: variance))
                expect(perlin.noise(for: points[5])).to(beCloseTo(-0.1859, within: variance))
                
                expect(perlin.noise(for: glkVector1)).to(beCloseTo(0.1936, within: variance))
                expect(perlin.normalizedNoise(for: glkVector2)).to(beCloseTo(0.4682, within: variance))
            }
        }
    }
}
