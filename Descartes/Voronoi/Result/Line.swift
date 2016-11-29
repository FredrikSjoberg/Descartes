//
//  Line.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

/// TODO: Switch names Segment<->Line to match conventions of a fixed vs unbounded (possibly) "line"
/// https://www.khanacademy.org/math/basic-geo/basic-geo-lines/basic-geo-lines-rays-angles/v/lines-line-segments-and-rays
public struct Line : Equatable {
    public let p0: CGPoint
    public let p1: CGPoint
    
    public init(p0: CGPoint, p1: CGPoint) {
        self.p0 = p0
        self.p1 = p1
    }
    
    public func intersects(line: Line) -> Bool {
        let c = line.p0-p0
        let r = vector
        let s = line.vector
        
        let cxr = c.cross(point: r)
        let cxs = c.cross(point: s)
        let rxs = r.cross(point: s)
        
        // Lines are colinear.
        if cxr == 0 {
            // Only intersect if they overlap
            let ol1 = ((line.p0.x - p0.x < 0) != (line.p0.x - p1.x < 0))
            let ol2 = ((line.p0.y - p0.y < 0) != (line.p0.y - p1.y < 0))
            return ol1 || ol2
        }
        
        // Parallel
        if rxs == 0 { return false }
        
        let rxsr = 1 / rxs
        let t = cxs * rxsr
        let u = cxr * rxsr
        
        return (t >= 0) && (t <= 1) && (u >= 0) && (u <= 1)
    }
    
    public var vector: CGPoint {
        return p1-p0
    }
}

public func == (lhs: Line, rhs: Line) -> Bool {
    return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1
}
