//
//  SegmentTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class SegmentTests: QuickSpec {
    override func spec() {
        let p0 = CGPoint.zero
        let p1 = CGPoint(x: 1, y: 1)
        let equation = LineEquation(p0: p0, p1: p1)
        describe("init") {
            it("should initialize correctly") {
                let segment = Segment(p0: p0, p1: p1, equation: equation)
                expect(segment.p0) == p0
                expect(segment.p1) == p1
                
                let s2 = Segment(p0: nil, p1: p1, equation: equation)
                expect(s2.p0).to(beNil())
                expect(s2.p1) == p1
                
                let s3 = Segment(p0: p0, p1: nil, equation: equation)
                expect(s3.p0) == p0
                expect(s3.p1).to(beNil())
            }
        }
    }
}
