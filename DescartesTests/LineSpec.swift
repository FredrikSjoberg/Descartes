//
//  LineSpec.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class LineSpec: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 10)
        let p1 = CGPoint(x: 10, y: 10)
        let p2 = CGPoint(x: 0, y: 5)
        let p3 = CGPoint(x: 10, y: 0)
        let l0 = Line(p0: CGPoint.zero, p1: p0)
        //let line1 = Line(p0: CGPoint.zero, p1: )
        describe("Intersection") {
            let parallelToL0 = Line(p0: p0+2, p1: p1+2)
            it("should not intersect parallel lines") {
                expect(l0.intersects(line: parallelToL0)) == false
            }
            
            it("should not intersec non onverlapping lines") {
                let second = Line(p0: p1, p1: p1*2)
                expect(l0.intersects(line: second)) == false
            }
            
            it("should not intersect non overlapping colinear lines") {
                let first = Line(p0: CGPoint.zero, p1: p2)
                let second = Line(p0: CGPoint(x: 0, y:6), p1: p0)
                expect(first.intersects(line: second)) == false
            }
            
            it("should intersect overlapping colinear lines") {
                let first = Line(p0: CGPoint.zero, p1: p2)
                let second = Line(p0: CGPoint(x: 0, y:4), p1: p0)
                expect(first.intersects(line: second)) == true
            }
            
            it("should intersect overlapping lines") {
                let first = Line(p0: CGPoint.zero, p1: p1)
                let second = Line(p0: p0, p1: p3)
                expect(first.intersects(line: second)) == true
            }
        }
        
        describe("Vector") {
            it("should produce vector") {
                expect(l0.vector) == p0
            }
        }
        
        describe("Equatable") {
            it("should equate lines with same points") {
                let second = Line(p0: CGPoint.zero, p1: p0)
                expect(l0 == second) == true
            }
            
            it("should not equate lines with swaped start/end points") {
                let second = Line(p0: p0, p1: CGPoint.zero)
                expect(l0 == second) == false
            }
            
            it("should not equate lines with different start or end points") {
                let second = Line(p0: CGPoint.zero, p1: p1)
                expect(l0 == second) == false
                
                let third = Line(p0: p3, p1: p0)
                expect(l0 == third) == false
            }
        }
    }
}
