//
//  Halfedge.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal class Halfedge {
    internal weak var next: Halfedge?
    internal weak var leftNeighbor: Halfedge?
    internal weak var rightNeighbor: Halfedge?
    
    // 
    internal var deleted: Bool = false
    
    // Halfedge's coordinates in transformed Voronoi V* space
    private var transformedVertex: TransformedVertex?
    internal var transformedPoint: CGPoint {
        if let transformed = transformedVertex {
            return transformed.transformedPoint
        }
        else {
            return CGPoint(x: Float.NaN, y: Float.NaN)
        }
    }
    internal var actualPoint: CGPoint? {
        return transformedVertex?.actualPoint
    }
    
    
    internal let edge: Edge?
    
    internal let orientation: Orientation
    
    init(edge: Edge?, orientation: Orientation) {
        self.edge = edge
        self.orientation = orientation
    }
    
    internal class func seed() -> Halfedge {
        return Halfedge(edge: nil, orientation: .Left)
    }
}

internal extension Halfedge {
    internal func intersect(halfedge: Halfedge) -> CGPoint? {
        if let edge0 = edge, let edge1 = halfedge.edge {
            if let reference = intersectionReference(halfedge),
                let intersection = edge0.equation.intersection(edge1.equation) {
                
                    let rightOfSite = (intersection.x >= reference.edge.rightSite.point.x)
                    
                    if (rightOfSite && halfedge.orientation == .Left) || (!rightOfSite && halfedge.orientation == .Right) {
                        return nil
                    }
                    
                    // Intersection valid
                    return intersection
            }
            else {
                // Edges does not intersect
                return nil
            }
        }
        else {
            // Halfedge(s) without ascociated Edge(s) can never intersect since they lack a lineEquation.
            return nil
        }
    }
    
    private func intersectionReference(halfedge: Halfedge) -> (halfedge: Halfedge, edge: Edge)? {
        if let edge0 = edge, let edge1 = halfedge.edge {
            if edge0.rightSite === edge1.rightSite {
                // Edges are straight lines, not curved
                return nil
            }
            
            //if CGPoint.compareYThenX(edge0.rightSite.point, point1: edge1.rightSite.point) {
            if edge0.rightSite.point.compareYThenX(edge1.rightSite.point) {
                return (self, edge0)
            }
            else {
                return (self, edge1)
            }
        }
        return nil
    }
}

internal extension Halfedge {
    internal func isLeftOf(point: CGPoint) -> Bool {
        if let edge = edge {
            let topSite = edge.rightSite
            let rightOfSite = point.x > topSite.point.x
            
            // Basic conditions
            if rightOfSite && orientation == .Left { return true }
            
            if !rightOfSite && orientation == .Right { return false }
            
            // Else
            var above: Bool
            if edge.equation.a == 1 {
                let dy = Float(point.y - topSite.point.y)
                let dx = Float(point.x - topSite.point.x)
                
                var fast = false
                
                if (!rightOfSite && edge.equation.b < 0) || (rightOfSite && edge.equation.b >= 0) {
                    above = (dy >= edge.equation.b*dx)
                    fast = above
                }
                else {
                    above = (Float(point.x + point.y) * edge.equation.b) > edge.equation.c
                    if edge.equation.b < 0 { above = !above }
                    
                    if !above { fast = true }
                }
                
                if !fast {
                    let dxs = Float(topSite.point.x - edge.leftSite.point.x)
                    above = ( (edge.equation.b*(dx*dx - dy*dy)) < (dxs*dy*(1 + 2*dx/dxs + edge.equation.b*edge.equation.b)) )
                    
                    if edge.equation.b < 0 { above = !above }
                }
            }
            else {
                let y = edge.equation.c - edge.equation.a * Float(point.x)
                let t1 = Float(point.y) - y
                let t2 = Float(point.x - topSite.point.x)
                let t3 = y - Float(topSite.point.y)
                above = (t1*t1 > t2*t2 + t3*t3)
            }
            
            return (orientation == .Left ? above : !above)
        }
        else {
            // FIXME: What happens if no edge is attached to this halfedge? Can we use transformedVertex?
            print("Warning: isLeftOf:\(point) | No edge assigned to Halfedge")
            return false
        }
    }
}

internal extension Halfedge {
    internal func setVertex(vertex: CGPoint, relativeTo site: Site) {
        transformedVertex = TransformedVertex(actualPoint: vertex, yStar: (Float(vertex.y) + vertex.distance(site.point)))
    }
}

extension Halfedge : Equatable { }
internal func ==(lhs: Halfedge, rhs: Halfedge) -> Bool {
    return lhs === rhs
}