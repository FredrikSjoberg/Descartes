//
//  EdgeTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 18/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class EdgeTests: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        let eq = LineEquation(p0: p0, p1: p1)
        let s0 = Site(point: p0)
        let s1 = Site(point: p1)
        let edge = Edge(left: s0, right: s1)
        describe("init") {
            it("should set left and right site correctly") {
                expect(edge.leftSite) == s0
                expect(edge.rightSite) == s1
            }
            
            it("should calculate line eq") {
                expect(edge.equation.a) == eq.a
                expect(edge.equation.b) == eq.b
                expect(edge.equation.c) == eq.c
            }
            
            it("should append self to site.edges") {
                expect(edge.leftSite.edges.count) > 0
                expect(edge.rightSite.edges.count) > 0
                expect(edge.leftSite.edges.first!) === edge
                expect(edge.rightSite.edges.first!) === edge
            }
        }
        
        describe("Sites") {
            it("should return site by orientation") {
                expect(edge.site(with: .left)) == s0
                expect(edge.site(with: .right)) == s1
            }
        }
        
        let v0 = CGPoint(x: 1, y: 9)
        let v1 = CGPoint(x: 9, y: 1)
        let bounds = CGRect(x: 2, y: 2, width: 6, height: 6)
        describe("Clipping Vertices") {
            
            it("should set vertices by orientation") {
                edge.set(vertex: v0, with: .left)
                edge.set(vertex: v1, with: .right)
                
                expect(edge.leftVertex).toNot(beNil())
                expect(edge.rightVertex).toNot(beNil())
                
                expect(edge.leftVertex!) == v0
                expect(edge.rightVertex!) == v1
            }
            
            it("should not contain a voronoiEdge before vertices are clipped") {
                expect(edge.voronoiEdge).to(beNil())
            }
            
            it("should contain a delaunayLine") {
                expect(edge.delaunayLine.p0) == p0
                expect(edge.delaunayLine.p1) == p1
            }
            
            it("should not be visible unless vertices have been clipped") {
                expect(edge.clippedVertices).to(beNil())
                expect(edge.visible) == false
            }
            
            let clip0 = CGPoint(x: 8, y: 2)
            let clip1 = CGPoint(x: 2, y: 8)
            it("should clip vertices") {
                edge.clipVertices(by: bounds)
                
                expect(edge.clippedVertices).toNot(beNil())
                expect(edge.visible) == true
                
                let clippedVertices = edge.clippedVertices!
                
                expect(clippedVertices.p0) == clip0
                expect(clippedVertices.p1) == clip1
            }
            
            let other = Edge(left: Site(point: CGPoint(x: 0, y: 10)), right: Site(point: CGPoint(x: 10, y: 0)))
            it("should switch vertices on clipping depending on line equation") {
                
                other.set(vertex: v0, with: .left)
                other.set(vertex: v1, with: .right)
                
                other.clipVertices(by: bounds)
                
                let clippedVertices = other.clippedVertices!
                
                expect(clippedVertices.p0) == CGPoint(x: 2, y: 2)
                expect(clippedVertices.p1) == CGPoint(x: 8, y: 8)
            }
            
            it("should contain voronoiEdge after clipping") {
                let voronoiEdge = edge.voronoiEdge
                expect(voronoiEdge).toNot(beNil())
                
                expect(voronoiEdge!.p0) == clip0
                expect(voronoiEdge!.p1) == clip1
            }
            
            it("should not contain a voronoiEdge if clipped vertices coincide") {
                edge.set(vertex: v0, with: .left)
                edge.set(vertex: v0, with: .right)
                edge.clipVertices(by: bounds)
                
                expect(edge.voronoiEdge).to(beNil())
            }
            
            it("should contain a dual node graph") {
                expect(edge.dualGraph.voronoi).to(beNil())
            }
        }
    }
}
