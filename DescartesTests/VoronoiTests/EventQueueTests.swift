//
//  EventQueueTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class EventQueueTests: QuickSpec {
    override func spec() {
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 10, y: 10)
        
        var s0: Site!
        var s1: Site!
        var edge: Edge!
        var halfedge: Halfedge!
        
        var queue: EventQueue!
        beforeEach {
            queue = EventQueue()
            
            s0 = Site(point: p0)
            s1 = Site(point: p1)
            edge = Edge(left: s0, right: s1)
            halfedge = Halfedge(edge: edge, orientation: .left)
            let vertex = TransformedVertex(vertex: CGPoint(x: 0, y: 10), relativeTo: s0)
            
            queue.insert(halfedge: halfedge, withIntersection: vertex)
        }
        
        describe("Manage") {
            it("should remove correctly") {
                queue.remove(halfedge: halfedge)
                expect(queue.isEmpty).to(beTrue())
            }
            
            it("should handle pop and peek") {
                let value = queue.peek()
                expect(value).notTo(beNil())
                expect(value!) == halfedge
                expect(queue.isEmpty).to(beFalse())
                
                let popped = queue.pop()
                expect(popped).notTo(beNil())
                expect(popped!) == halfedge
                expect(queue.isEmpty).to(beTrue())
            }
            
            it("should preserve order on inserts and removes") {
                let otherHalfedge = Halfedge(edge: edge, orientation: .right)
                let vertex = TransformedVertex(vertex: CGPoint(x: 10, y: 6), relativeTo: s1)
                queue.insert(halfedge: otherHalfedge, withIntersection: vertex)
                
                var min = queue.minPoint
                expect(min).toNot(beNil())
                expect(min!) == vertex.transformedPoint
                
                let _ = queue.pop()
                
                min = queue.minPoint
                expect(min).toNot(beNil())
                expect(min!) == halfedge.intersectionVertex!.transformedPoint
            }
        }
    }
}
