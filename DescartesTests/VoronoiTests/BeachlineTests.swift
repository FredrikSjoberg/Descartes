//
//  BeachlineTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class BeachlineTests: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        var beachline: BeachLine!
        
        beforeEach {
            beachline = BeachLine()
        }
        
        describe("Manage") {
            it("should get dummy for 'empty' leftNeighbor") {
                expect(beachline.leftNeighbor(for: CGPoint.zero).edge).to(beNil())
            }
            
            it("should insert first halfedge between dummies") {
                let s0 = Site(point: p0)
                let s1 = Site(point: p1)
                let edge = Edge(left: s0, right: s1)
                let halfedge = Halfedge(edge: edge, orientation: .left)
                
                let leftend = beachline.leftNeighbor(for: CGPoint.zero)
                expect(leftend.edge).to(beNil())
                expect(leftend.right).toNot(beNil())
                expect(leftend.right!.edge).to(beNil())
                
                beachline.insert(halfedge: halfedge, rightOf: leftend)
                
                let retrieved = beachline.leftNeighbor(for: CGPoint(x: 20, y: 0))
                expect(retrieved) == halfedge
                expect(retrieved.left).toNot(beNil())
                expect(retrieved.left!.edge).to(beNil())
                expect(retrieved.right).toNot(beNil())
                expect(retrieved.right!.edge).to(beNil())
            }
            
            it("should remove halfedge correctly") {
                let s0 = Site(point: p0)
                let s1 = Site(point: p1)
                let edge = Edge(left: s0, right: s1)
                let halfedge = Halfedge(edge: edge, orientation: .left)
                
                let leftend = beachline.leftNeighbor(for: CGPoint.zero)
                beachline.insert(halfedge: halfedge, rightOf: leftend)
                
                expect(halfedge.left).toNot(beNil())
                expect(halfedge.right).toNot(beNil())
                
                beachline.remove(halfedge: halfedge)
                
                expect(halfedge.left).to(beNil())
                expect(halfedge.right).to(beNil())
                
                let retrieved = beachline.leftNeighbor(for: CGPoint(x: 20, y: 0))
                expect(retrieved.edge).to(beNil())
                expect(retrieved.right).toNot(beNil())
                expect(retrieved.right!.edge).to(beNil())
            }
        }
    }
}
