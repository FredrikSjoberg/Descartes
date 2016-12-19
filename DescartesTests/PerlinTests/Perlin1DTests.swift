//
//  Perlin1DTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class Perlin1DTests: QuickSpec {
    override func spec() {
        let variance = 0.0001
        describe("Deterministic") {
            it("should generate same results every time") {
                let perlin = Perlin1D(octaves: 4, frequency: 4, amplitude: 1, seed: 1)
                expect(perlin.noise(for: 0.0)).to(beCloseTo(0, within: variance))
                expect(perlin.noise(for: 0.1)).to(beCloseTo(0.7079, within: variance))
                expect(perlin.noise(for: 0.2)).to(beCloseTo(0.2765, within: variance))
                expect(perlin.noise(for: 0.3)).to(beCloseTo(-0.3899, within: variance))
                expect(perlin.normalizedNoise(for: 0.3)).to(beCloseTo(0.3050, within: variance))
                expect(perlin.noise(for: 0.4)).to(beCloseTo(-0.1548, within: variance))
                expect(perlin.noise(for: 0.5)).to(beCloseTo(0, within: variance))
                expect(perlin.normalizedNoise(for: 0.6)).to(beCloseTo(0.3870, within: variance))
                expect(perlin.normalizedNoise(for: 0.7)).to(beCloseTo(0.5441, within: variance))
                expect(perlin.normalizedNoise(for: 0.8)).to(beCloseTo(0.5694, within: variance))
                expect(perlin.normalizedNoise(for: 0.9)).to(beCloseTo(0.8005, within: variance))
                expect(perlin.normalizedNoise(for: 1.0)).to(beCloseTo(0.5, within: variance))
            }
        }
    }
}
