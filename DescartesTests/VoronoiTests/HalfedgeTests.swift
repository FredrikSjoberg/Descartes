//
//  HalfedgeTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 18/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class HalfedgeTests: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        
        var s0: Site!
        var s1: Site!
        var edge: Edge!
        var halfedge: Halfedge!
        beforeEach{
            s0 = Site(point: p0)
            s1 = Site(point: p1)
            edge = Edge(left: s0, right: s1)
            halfedge = Halfedge(edge: edge, orientation: .left)
        }
        
        describe("init") {
            it("should initialize with parameters") {
                expect(halfedge.edge).toNot(beNil())
                expect(halfedge.orientation).toNot(beNil())
            }
            
            it("should init without paramenters") {
                let empty = Halfedge()
                expect(empty.edge).to(beNil())
                expect(empty.orientation).to(beNil())
            }
            
            it("should create as dummy") {
                let dummy = Halfedge.dummy()
                expect(dummy.edge).to(beNil())
                expect(dummy.orientation).to(beNil())
            }
        }
        
        describe("Intersection") {
            it("should not intersect if corresponding edges are nil") {
                let empty = Halfedge()
                let dummy = Halfedge.dummy()
                expect(empty.intersects(other: dummy)).to(beNil())
            }
            
            
            let point0 = p0+5
            let point1 = p1+5
            let otherEq = LineEquation(p0: point0, p1: point1)
            let otherSite0 = Site(point: point0)
            let otherSite1 = Site(point: point1)
            let otherEdge = Edge(left: otherSite0, right: otherSite1)
            let otherHalfedge = Halfedge(edge: otherEdge, orientation: .left)
            it("should not intersect if right sites are the same") {
                let otherSite = Site(point: CGPoint.zero)
                let otherEdge = Edge(left: otherSite, right: s1)
                let other = Halfedge(edge: otherEdge, orientation: .left)
                
                expect(otherSite).toNot(beNil())
                expect(halfedge.intersects(other: other)).to(beNil())
            }
            
            let eq = LineEquation(p0: p0, p1: p1)
            it("should not intersect if edge equations do not intersect") {
                // NOTE: edge.rightSite is unowned, we need to keep a reference around else it goes out of scope.
                // This is a primary bugfix
                expect(otherSite0).toNot(beNil())
                expect(otherSite1).toNot(beNil())
                
                expect(eq.intersects(eq: otherEq)).to(beNil())
                expect(halfedge.intersects(other: otherHalfedge)).to(beNil())
            }
            
            it("should not intersect if orientation is .left and intersection's x-coord is to the right of other.edge's right site") {
//                
//                *
//            ----+------>x (intersection)
//                *  *   /
//                    \ / (1)
//                     X
//                    / *
//                   /
//
//              If orientation of (1) is left, ie pointing away from intersection, the intersection is NOT valid.
//              Else, if (1) points towards intersection, it is a valid intersection
//
                let vs1 = Site(point: CGPoint(x: 0, y: 10))
                let evertical = Edge(left: Site(point: p0), right: vs1)
                let ss0 = Site(point: CGPoint(x: 5, y: 0))
                let ss1 = Site(point: CGPoint(x: 10, y: -5))
                let eslanted = Edge(left: ss0, right: ss1)
                let horizontal = Halfedge(edge: evertical, orientation: .right)
                let slantedRight = Halfedge(edge: eslanted, orientation: .right)
                let slantedLeft = Halfedge(edge: eslanted, orientation: .left)
                
                expect(horizontal.intersects(other: slantedLeft)).to(beNil())
                expect(horizontal.intersects(other: slantedRight)).toNot(beNil())
            }
            
            it("should not intersect if orientation is .right and intersection's x-coord is to the left of other.edge's right site") {
//                
//                           *
//                            X
//                       (1) / \
//                *         /   *
//            ----+------->x
//                *         (intersection)
//                
//              Reverse from test above
                
                let vs1 = Site(point: CGPoint(x: 0, y: 10))
                let evertical = Edge(left: Site(point: p0), right: vs1)
                let ss0 = Site(point: CGPoint(x: 5, y: 0))
                let ss1 = Site(point: CGPoint(x: 15, y: -5))
                let eslanted = Edge(left: ss0, right: ss1)
                let horizontal = Halfedge(edge: evertical, orientation: .right)
                let slantedRight = Halfedge(edge: eslanted, orientation: .right)
                let slantedLeft = Halfedge(edge: eslanted, orientation: .left)
                
                expect(horizontal.intersects(other: slantedRight)).to(beNil())
                expect(horizontal.intersects(other: slantedLeft)).toNot(beNil())
            }
            
            let is0 = Site(point: CGPoint(x: 0, y: 10))
            let is1 = Site(point: CGPoint(x: 10, y: 0))
            let iedge = Edge(left: is0, right: is1)
            let ihalfedge = Halfedge(edge: iedge, orientation: .left)
            
            it("should intersect properly") {
                // This is a primary bugfix: See above for capturing sites in scope to avoid release by ARC.
                expect(is0).toNot(beNil())
                expect(is1).toNot(beNil())
                
                expect(ihalfedge.intersects(other: halfedge)).toNot(beNil())
                expect(halfedge.intersects(other: ihalfedge)).toNot(beNil())
            }
        }
        
        describe("Left Of") {
            let leftOf = CGPoint(x: 9, y: 10)
            it("depends on orientation and locaion of point relative to edge's righSite") {
                let rightOf = CGPoint(x: 11, y: 10)
                expect(halfedge.isLeft(of: rightOf)).to(beTrue())
                
                let rightFacing = Halfedge(edge: edge, orientation: .right)
                expect(rightFacing.isLeft(of: leftOf)).to(beFalse())
            }
            
            it("requires edge") {
                // NOTE: This test equates to the terrible asumption that any point is left of a halfedge without an associated edge. NOT a prudent way of thinking, since the side effects includes that dummy edges are allways left of any point.
                let anyPoint = CGPoint(x: 5, y: 5)
                expect(Halfedge.dummy().isLeft(of: anyPoint)).to(beTrue())
            }
            
            it("depends on edge equation") {
                expect(halfedge.isLeft(of: leftOf)).to(beFalse())
                
                let pt = CGPoint(x: 4, y: -4)
                let is1 = Site(point: CGPoint(x: 10, y: -5))
                let sedge = Edge(left: s0, right: is1)
                let leftFacing = Halfedge(edge: sedge, orientation: .left)
                let rightFacing = Halfedge(edge: sedge, orientation: .right)
                
                // a == 1
                expect(leftFacing.isLeft(of: pt)).to(beFalse())
                expect(rightFacing.isLeft(of: pt)).to(beFalse())
                
                // Not above right site
                let rightFacing2 = Halfedge(edge: edge, orientation: .right)
                expect(rightFacing2.isLeft(of: CGPoint(x: 11, y: 5))).to(beTrue())
                
                // a != 1 && b == 1
                let is2 = Site(point: CGPoint(x: 5, y: 10))
                let edge2 = Edge(left: s0, right: is2)
                let halfedge2 = Halfedge(edge: edge2, orientation: .left)
                
                expect(halfedge2.isLeft(of: CGPoint(x: 2, y: 3))).to(beFalse())
            }
        }
        
        describe("Equatable") {
            it("should equate properly") {
                let sameContents = Halfedge(edge: edge, orientation: .left)
                
                expect(halfedge == halfedge).to(beTrue())
                expect(halfedge == sameContents).to(beFalse())
            }
            
            
            
            
            
            
            
            
            
            
        }
    }
}
