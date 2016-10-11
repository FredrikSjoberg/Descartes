//
//  EventQueue.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 02/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation

import Foundation
import CoreGraphics

internal class EventQueue {
    fileprivate var heap: Heap<Halfedge> = Heap{ $0.intersectionVertex!.yStar < $1.intersectionVertex!.yStar } // NOTE: By design, all halfedges added to the EventQueue will have an intersectionVertex
    
    
    internal func insert(halfedge: Halfedge, withIntersection vertex: TransformedVertex) {
        halfedge.intersectionVertex = vertex
        heap.push(element: halfedge)
    }
    
    internal func remove(halfedge: Halfedge) {
        heap.invalidate(element: halfedge)
    }
    
    internal func pop() -> Halfedge? {
        return heap.pop()
    }
    
    internal func peek() -> Halfedge? {
        return heap.peek()
    }
    
    internal var minPoint: CGPoint? {
        return heap.peek()?.intersectionVertex?.transformedPoint
    }
    
    
    internal var isEmpty: Bool {
        return heap.isEmpty
    }
}
