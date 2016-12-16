//
//  CGRectTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class CGRectSpec: QuickSpec {
    override func spec() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let bottomLeft = CGPoint.zero
        let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let topLeft = CGPoint(x: rect.minY, y: rect.maxY)
        describe("Corners") {
            it("should return correct corners") {
                expect(rect.bottomLeft) == bottomLeft
                expect(rect.bottomRight) == bottomRight
                expect(rect.topRight) == topRight
                expect(rect.topLeft) == topLeft
            }
            
            it("should return corners in clockwise order") {
                expect([bottomLeft, topLeft, topRight, bottomRight]) == rect.cornerPoints
            }
        }
        
        describe("Edges") {
            it("should return correct edges") {
                let bottomEdge = Line(p0: bottomLeft, p1: bottomRight)
                let leftEdge = Line(p0: topLeft, p1: bottomLeft)
                let topEdge = Line(p0: topRight, p1: topLeft)
                let rightEdge = Line(p0: bottomRight, p1: topRight)
                expect(rect.bottomEdge) == bottomEdge
                expect(rect.leftEdge) == leftEdge
                expect(rect.topEdge) == topEdge
                expect(rect.rightEdge) == rightEdge
            }
            
            it("should require correct order for p0 and p1 in lines") {
                let bottomEdge = Line(p0: bottomRight, p1: bottomLeft)
                let leftEdge = Line(p0: bottomLeft, p1: topLeft)
                let topEdge = Line(p0: topLeft, p1: topRight)
                let rightEdge = Line(p0: topRight, p1: bottomRight)
                expect(rect.bottomEdge) != bottomEdge
                expect(rect.leftEdge) != leftEdge
                expect(rect.topEdge) != topEdge
                expect(rect.rightEdge) != rightEdge
            }
        }
        
        let notIntersecting = Line(p0: CGPoint(x:12, y: 12), p1: CGPoint(x: 15, y: 15))
        describe("Intersection") {
            let intersecting = Line(p0: CGPoint(x:5, y: 5), p1: CGPoint(x: 5, y: 15))
            let inside = Line(p0: CGPoint(x:2, y: 2), p1: CGPoint(x: 5, y: 5))
            let onBorder = [rect.leftEdge, rect.bottomEdge, rect.rightEdge, rect.topEdge]
            it("should intersect lines crossing rectangle border") {
                expect(rect.intersects(lines: [intersecting, notIntersecting, inside])) == true
            }
            
            it("should not intersect lines inside or outside but not crossing border") {
                expect(rect.intersects(lines: [notIntersecting, inside])) == false
            }
            
            it("should intersect lines paralell with border") {
                expect(rect.intersects(lines: onBorder)) == true
            }
        }
        
        describe("Quarternized") {
            let quarterSize = CGSize(width: rect.width/2, height: rect.height/2)
            let subdivided = [
                CGRect(x: 0, y: 0, width: 5, height: 5),
                CGRect(x: 0, y: 5, width: 5, height: 5),
                CGRect(x: 5, y: 5, width: 5, height: 5),
                CGRect(x: 5, y: 0, width: 5, height: 5)
            ]
            
            it("should calculate quartersize") {
                expect(rect.quarterSize) == quarterSize
            }
            
            it("should return subdivision in clockwise order") {
                expect(rect.quarternize()) == subdivided
            }
            
            let minSize = CGSize(width: quarterSize.width/2, height: quarterSize.height/2)
            let line = [Line(p0: CGPoint(x: 8, y: 12), p1: CGPoint(x: 12, y: 8))]
            it("should not split when limit is reached") {
                expect(rect.splitIntersect(line, minSize: minSize)) == subdivided
            }
            
            
            it("should split when increaseDepth is supplied") {
                var split = [subdivided[0],
                             subdivided[1]]
                split.append(contentsOf: subdivided[2].quarternize())
                split.append(subdivided[3])
                
                expect(rect.splitIntersect(line, minSize: minSize, increaseDepth: true)) == split
            }
            
            it("should return self if no intersection is found") {
                expect(rect.splitIntersect([notIntersecting], minSize: minSize)) == [rect]
            }
        }
    }
}
