//
//  LineEquationTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class LineEquationSpec: QuickSpec {
    override func spec() {
        let p0 = CGPoint.zero
        let p1 = CGPoint(x: 10, y: 0)
        let p2 = CGPoint(x: 0, y: 10)
        
        let one: CGFloat = 1
        
        let eq0 = LineEquation(p0: p0, p1: p1)
        let eq1 = LineEquation(p0: p0, p1: p2)
        describe("init") {
            it("should create perpendicular line eq halfway between p0 & p1 correctly when dx > dy") {
                let dx = p1.x-p0.x
                let dy = p1.y-p0.y
                let c = p0.x*dx + p0.y*dy + (dx*dx + dy*dy)/2
                
                expect(eq0.a) == one
                expect(eq0.b) == dy/dx
                expect(eq0.c) == c/dx
            }
            
            it("should create perpendicular line eq halfway between p0 & p1 correctly when dx < dy") {
                let dx = p2.x-p0.x
                let dy = p2.y-p0.y
                let c = p0.x*dx + p0.y*dy + (dx*dx + dy*dy)/2
                
                expect(eq1.a) == dx/dy
                expect(eq1.b) == one
                expect(eq1.c) == c/dy
            }
        }
        
        describe("Determinant") {
            it("should calculate") {
                let det = eq0.a * eq1.b - eq0.b * eq1.a
                expect(eq0.determinant(with: eq1)) == det
            }
        }
        
        let parallelWithEq0 = LineEquation(p0: CGPoint(x: p0.x, y: p0.y+1), p1: CGPoint(x: p1.x, y: p1.y+1))
        describe("isParallel") {
            it("should determine if parallel within bounds (epsilon)") {
                
                expect(eq0.isParallel(to: eq1)) == false
                expect(eq0.isParallel(to: parallelWithEq0)) == true
            }
        }
        
        describe("Intersects") {
            it("should not intersect paralell lines") {
                expect(eq0.intersects(eq: parallelWithEq0)).to(beNil())
                expect(eq0.intersects(eq: eq0)).to(beNil())
            }
            
            it("should return intersection") {
                let line1 = LineEquation(p0: CGPoint(x: 0, y: 0),
                                         p1: CGPoint(x: 6, y: 6))
                let line2 = LineEquation(p0: CGPoint(x: 0, y: 6),
                                         p1: CGPoint(x: 6, y: 0))
                
                expect(line1.intersects(eq: line2)) == CGPoint(x: 3, y: 3)
                
                let horizontal = LineEquation(p0: CGPoint(x: -5, y: 0),
                                              p1: CGPoint(x: 5, y: 0))
                let vertical = LineEquation(p0: CGPoint(x: 0, y: -5),
                                              p1: CGPoint(x: 0, y: 5))
                expect(horizontal.intersects(eq: vertical)) == CGPoint.zero
                
                
                expect(eq0.intersects(eq: eq1)) == CGPoint(x: 5, y: 5)
            }
        }
    }
}
