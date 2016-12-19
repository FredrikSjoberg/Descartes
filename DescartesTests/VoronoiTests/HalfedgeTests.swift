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
            
           /* it("should not intersect if orientation is .left and intersection's x-coord is to the right of reference edges right site") {
                
            }
            
            it("should not intersect if orientation is .right and intersection's x-coord is to the left of reference edges right site") {
                
            }*/
            
            let is0 = Site(point: CGPoint(x: 0, y: 10))
            let is1 = Site(point: CGPoint(x: 10, y: 0))
            let iedge = Edge(left: is0, right: is1)
            let ihalfedge = Halfedge(edge: iedge, orientation: .left)
            
            it("should intersect properly") {
                // This is a primary bugfix: See above for capturing sites in scope to avoid release by ARC.
                expect(is0).toNot(beNil())
                expect(is1).toNot(beNil())
                
                expect(ihalfedge.intersects(other: halfedge)).toNot(beNil())
            }
        }
    }
}
