//
//  Perlin3DTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import GLKit
import SceneKit
@testable import Descartes

class Perlin3DTests: QuickSpec {
    override func spec(){
        let variance = 0.0001
        
        let glkVector = GLKVector3(v: (0.1, 0.5, 0.6))
        let glkVector2 = GLKVector3(v: (0.4, 0.2, 0.8))
        let glkVector3 = GLKVector3(v: (0.9, 0.9, 0.9))
        let scnVector = SCNVector3(0.1, 0.5, 0.6)
        let scnVector2 = SCNVector3(0.4, 0.2, 0.8)
        
        describe("Deterministic") {
            it("should generate same results every time") {
                let perlin = Perlin3D(octaves: 8, frequency: 8, amplitude: 1, seed: 1)
                
                
                expect(perlin.noise(for: glkVector)).to(beCloseTo(-0.2217, within: variance))
                expect(perlin.normalizedNoise(for: glkVector2)).to(beCloseTo(0.5080, within: variance))
                
                expect(perlin.noise(for: glkVector3)).to(beCloseTo(0.0151, within: variance))
                
                expect(perlin.noise(for: scnVector)).to(beCloseTo(-0.2217, within: variance))
                expect(perlin.normalizedNoise(for: scnVector2)).to(beCloseTo(0.5080, within: variance))
            }
        }
    }
}

