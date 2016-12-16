//
//  FloatTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class FloatSpec: QuickSpec {
    override func spec() {
        let value: Float = 10
        describe("sCurve") {
            it("should calculate") {
                expect(value.sCurve) == value*value*(3-2*value)
            }
        }
        
        describe("Lerp") {
            it("should calculate") {
                expect(value.lerp(a: 0.1, b: 0.9)) == 0.1 + value*(0.9-0.1)
            }
        }
    }
}
