//
//  IntTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class IntSpec: QuickSpec {
    override func spec() {
        describe("Clamp") {
            it("should clamp between values") {
                expect(7.clamp(0, 5)) == 5
                expect((-1).clamp(0, 5)) == 0
                expect((-7).clamp(-5, 0)) == -5
                expect(2.clamp(-5, 0)) == 0
            }
        }
    }
}
