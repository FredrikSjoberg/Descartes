//
//  CGPointTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class CGPointSpec: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 10)
        let p1 = p0+1
        let p2 = CGPoint(x: 10, y: 10)
        let line = Line(p0: p0, p1: p2)
        describe("init") {
            it("should init with Floats") {
                expect(CGPoint(x: Float(0), y: Float(10))) == p0
            }
        }
        
        describe("Normalization") {
            it("should not crash on CGPoint.zero") {
                expect(CGPoint.zero.normalized) == CGPoint.zero
            }
            
            it("should calculate") {
                let point = CGPoint(x: 1, y: 1)
                let value:CGFloat = 1/sqrt(2)
                let second = CGPoint(x: point.x*value,
                                     y: point.y*value)
                expect(point.normalized) == second
            }
        }
        
        describe("Distance") {
            it("should calculate") {
                let distance: Float = sqrt(50)
                let second = CGPoint(x: 5, y: 5)
                expect(p0.distance(to: second)) == distance
            }
        }
        
        describe("Compare") {
            it("should compareYThenX") {
                let values = [
                    CGPoint(x: p0.x, y: p0.y+1),
                    p1,
                    CGPoint(x: p0.x, y: p0.y-1),
                    p0-1
                ]
                
                expect(values.sorted{ $0.compareYThenX(with: $1) } ) == [
                    p0-1,
                    CGPoint(x: p0.x, y: p0.y-1),
                    CGPoint(x: p0.x, y: p0.y+1),
                    p1
                    ]
                
                expect(CGPoint.compareYThenX(point0: values[0], point1: values[1])) == true
                
                expect(p1.compareYThenX(with: p0)) == false
                expect(CGPoint(x: p0.x+1, y: p0.y).compareYThenX(with: p0)) == false
                expect(CGPoint.zero.compareYThenX(with: CGPoint.zero)) == true
            }
        }
        
        describe("Dot") {
            it("should calculate") {
                let result:CGFloat = 1*10 + 11*10
                expect(p1.dot(point: p2)) == result
            }
        }
        
        describe("Cross") {
            it("should calculate") {
                let result: CGFloat = 1*10 - 10*11
                expect(p1.cross(point: p2)) == result
            }
        }
        
        describe("Colinear") {
            it("should be colinear with line") {
                expect(CGPoint(x: p0.x+5, y: p0.y).colinear(with: line)) == true
            }
            
            it("should be colinear with enpoints of line ") {
                expect(p0.colinear(with: line)) == true
            }
            
            it("should not be colinear with point not on line") {
                expect((p0+1).colinear(with: line)) == false
            }
        }
        
        describe("On Line") {
            it("should be on line") {
                expect(CGPoint(x: p0.x+5, y: p0.y).on(line: line)) == true
            }
            
            it("should be on line at extremePoints") {
                expect(p0.on(line: line)) == true
                expect(p2.on(line: line)) == true
            }
            
            it("should not be on line") {
                expect(CGPoint(x: p0.x+11, y: p0.y).on(line: line)) == false
                expect(CGPoint(x: p0.x-1, y: p0.y).on(line: line)) == false
                expect((p0+1).on(line: line)) == false
            }
        }
        
        describe("Hashable") {
            it("Shoud give valid hashvalue") {
                let hash = p0.x.hashValue << 32 ^ p0.y.hashValue
                expect(p0.hashValue) == hash
            }
        }
//        describe("Equatable") {
//            it("should equate") {
//                let point = CGPoint(x: 0, y: 10)
//                let t = p0 == point
//                expect(p0 == point) == true
//            }
//        }
        
        describe("Operators") {
            it("should calcualte") {
                expect(p0+p2) == CGPoint(x: 10, y: 20)
            }
        }
//                let val = 1
//                expect(p0+val) == p1
//                expect(p0*val) == CGPoint(x: p0.x*val, y: p0.y*val)
//                expect(p0-val) == CGPoint(x: p0.x-val, y: p0.y-val)
//            }
//        }
    }
}

