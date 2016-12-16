//
//  OrientationTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class OrientationSpec: QuickSpec {
    override func spec() {
        describe("Opposite") {
            it("should return opposite") {
                expect(Orientation.left.opposite) == Orientation.right
                expect(Orientation.right.opposite) == Orientation.left
            }
        }
    }
}
