//
//  BoundaryTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class BoundaryTypeTests: QuickSpec {
    override func spec() {
        
        
        describe("CGRect+Boundary") {
            let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
            let bottomLeft = CGPoint.zero
            let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
            let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
            let topLeft = CGPoint(x: rect.minY, y: rect.maxY)
            
            let bottomEdge = Line(p0: bottomLeft, p1: bottomRight)
            let leftEdge = Line(p0: topLeft, p1: bottomLeft)
            let topEdge = Line(p0: topRight, p1: topLeft)
            let rightEdge = Line(p0: bottomRight, p1: topRight)
            
            let eq = LineEquation(p0: CGPoint(x: 0, y: 0),
                                  p1: CGPoint(x: 10, y: 0))
            let eqh = LineEquation(p0: CGPoint(x: 0, y: 0),
                                   p1: CGPoint(x: 0, y: 10))
            describe("Borders") {
                it("should calculate borders") {
                    let borders = [bottomEdge, rightEdge, topEdge, leftEdge]
                    
                    expect(rect.borders) == borders
                    
                    let onLeft = rect.pointOnBorder(point: CGPoint(x: 0, y: 5))
                    expect(onLeft).toNot(beNil())
                    expect(onLeft!) == leftEdge
                    
                    let onTop = rect.pointOnBorder(point: CGPoint(x: 5, y: 10))
                    expect(onTop).toNot(beNil())
                    expect(onTop!) == topEdge
                    
                    let onRight = rect.pointOnBorder(point: CGPoint(x: 10, y: 5))
                    expect(onRight).toNot(beNil())
                    expect(onRight!) == rightEdge
                    
                    let onBottom = rect.pointOnBorder(point: CGPoint(x: 5, y: 0))
                    expect(onBottom).toNot(beNil())
                    expect(onBottom!) == bottomEdge
                    
                    expect(rect.pointOnBorder(point: CGPoint(x: 5, y: 5))).to(beNil())
                }
            }
            
            describe("should not clip") {
                it("when a == 1 and y0 > ymax") {
                    let v = CGPoint(x: 5, y: 11)
                    let segment = Segment(p0: v, p1: nil, equation: eq)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
                
                it("when a == 1 and  y1 < ymin") {
                    let v = CGPoint(x: 5, y: -1)
                    let segment = Segment(p0: nil, p1: v, equation: eq)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
                
                it("when a == 1 and x0 && x0 > xmax") {
                    let eq1 = LineEquation(p0: CGPoint(x: 11, y: 0),
                                           p1: CGPoint(x: 21, y: 0))
                    let v0 = CGPoint(x: 11, y: -1)
                    let v1 = CGPoint(x: 11, y: 11)
                    let segment = Segment(p0: v0, p1: v1, equation: eq1)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
                
                it("when b == 1 and x0 > xmax") {
                    let v = CGPoint(x: 11, y: 5)
                    let segment = Segment(p0: v, p1: nil, equation: eqh)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
                
                it("when b == 1 and  x1 < xmin") {
                    let v = CGPoint(x: -1, y: 5)
                    let segment = Segment(p0: nil, p1: v, equation: eqh)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
                
                it("when b == 1 and y0 && y0 > ymax") {
                    let eq1 = LineEquation(p0: CGPoint(x: 0, y: 11),
                                           p1: CGPoint(x: 0, y: 21))
                    let v0 = CGPoint(x: -1, y: 11)
                    let v1 = CGPoint(x: 11, y: 11)
                    let segment = Segment(p0: v0, p1: v1, equation: eq1)
                    expect(rect.clipVertices(of: segment)).to(beNil())
                }
            }
            
            
            describe("should clip") {
                it("both ends") {
                    let segment = Segment(p0: nil, p1: nil, equation: eqh)
                    expect(rect.clipVertices(of: segment)) == Line(p0: CGPoint(x: 0, y: 5), p1: CGPoint(x: 10, y: 5))
                }
                
                it("one end") {
                    let v0 = CGPoint(x: 0, y: 5)
                    let v1 = CGPoint(x: 10, y: 5)
                    
                    let segment0 = Segment(p0: v0, p1: nil, equation: eqh)
                    expect(rect.clipVertices(of: segment0)) == Line(p0: CGPoint(x: 0, y: 5), p1: CGPoint(x: 10, y: 5))
                    let segment1 = Segment(p0: nil, p1: v1, equation: eqh)
                    expect(rect.clipVertices(of: segment1)) == Line(p0: CGPoint(x: 0, y: 5), p1: CGPoint(x: 10, y: 5))
                }
            }
        }
    }
}
