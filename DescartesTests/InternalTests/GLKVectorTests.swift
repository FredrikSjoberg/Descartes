//
//  GLKVectorTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
import GLKit
@testable import Descartes

class GLKVector2Spec: QuickSpec {
    override func spec() {
        describe("cgPoint") {
            it("should convert") {
                let point = CGPoint(x: 10, y: 10)
                let vector = GLKVector2(v: (10,10))
                expect(vector.cgPoint) == point
            }
        }
    }
}
