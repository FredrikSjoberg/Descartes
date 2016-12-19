//
//  Halfedge.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal class Halfedge : Equatable {
    internal weak var left: Halfedge?
    internal weak var right: Halfedge?
    
    internal let edge: Edge?
    internal let orientation: Orientation?
    
    internal var intersectionVertex: TransformedVertex?
    
    internal init(edge: Edge, orientation: Orientation) {
        self.edge = edge
        self.orientation = orientation
    }
    
    internal init() {
        edge = nil
        orientation = nil
    }
    
    internal class func dummy() -> Halfedge {
        return Halfedge()
    }
    
    internal func intersects(other: Halfedge) -> CGPoint? {
        guard let e0 = edge, let e1 = other.edge else { return nil }
        
        guard e0.rightSite != e1.rightSite else { return nil }
        
        
        guard let intersection = e0.equation.intersects(eq: e1.equation) else { return nil }
        
        let reference = e0.rightSite.point.compareYThenX(with: e1.rightSite.point) ? (self, e0) : (other, e1)
        
        let rightOfSite = intersection.x >= reference.1.rightSite.point.x
        
        if (rightOfSite && reference.0.orientation == .left) || (!rightOfSite && reference.0.orientation == .right) {
            return nil
        }
        
        return intersection
    }
    
    internal func isLeft(of point: CGPoint) -> Bool {
        guard let edge = edge else {
            // TODO: This is terrible. If we ever decide to search from right->left, rightEnd will still be left of any point!
            return true
        }
        
        let topSite = edge.rightSite
        let rightOfSite = (point.x > topSite.point.x)
        
        if rightOfSite && orientation == .left {
            return true
        }
        
        if !rightOfSite && orientation == .right {
            return false
        }
        
        var above = false
        if edge.equation.a == 1 {
            let dy = point.y - topSite.point.y
            let dx = point.x - topSite.point.x
            
            var fast = false
            
            if (!rightOfSite && edge.equation.b < 0) || (rightOfSite && edge.equation.b >= 0) {
                above = (dy >= edge.equation.b * dx)
                fast = above
            }
            else {
                above = (point.x + point.y * edge.equation.b > edge.equation.c)
                if edge.equation.b < 0 {
                    above = !above
                }
                if !above {
                    fast = true
                }
            }
            
            if !fast {
                let dxs = topSite.point.x - edge.leftSite.point.x
                above = (edge.equation.b * (dx*dx - dy*dy) < dxs * dy * (1 + 2 * dx/dxs + edge.equation.b * edge.equation.b))
                if edge.equation.b < 0 {
                    above = !above
                }
            }
        }
        else {
            // edge.equation.b == 1
            let yl = edge.equation.c - edge.equation.a * point.x
            let t1 = point.y - yl
            let t2 = point.x - topSite.point.x
            let t3 = yl - topSite.point.y
            above = (t1*t1 > t2*t2 + t3*t3)
        }
        return (orientation == .left ? above : !above)
    }
}

func == (lhs: Halfedge, rhs: Halfedge) -> Bool {
    return lhs === rhs
}
