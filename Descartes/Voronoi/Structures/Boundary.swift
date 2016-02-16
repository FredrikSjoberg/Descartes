//
//  Boundary.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation

public protocol BoundaryType {
    func clipVertices(segment: Segment) -> Line?
    func contains(point: CGPoint) -> Bool
}

extension CGRect : BoundaryType {
    public func clipVertices(segment: Segment) -> Line? {
        let p0 = segment.p0
        let p1 = segment.p1
        
        let xmin = CGRectGetMinX(self)
        let xmax = CGRectGetMaxX(self)
        let ymin = CGRectGetMinY(self)
        let ymax = CGRectGetMaxY(self)
        
        // Ax + By = c
        // -> x = (c - By)/A
        if segment.equation.a == 1 {
            // y0
            var y0 = ymin
            if let p = p0 {
                if p.y > ymin {
                    y0 = p.y
                }
            }
            if y0 > ymax {
                // Illegal value
                return nil
            }
            
            // 1.0x + By = c
            // -> x = C - By
            var x0 = segment.equation.c - segment.equation.b*y0
            
            
            // y1
            var y1 = ymax
            if let p = p1 {
                if p.y < ymax {
                    y1 = p.y
                }
            }
            if y1 < ymin {
                // Illegal value
                return nil
            }
            
            // 1.0x + By = c
            // -> x = C - By
            var x1 = segment.equation.c - segment.equation.b*y1
            
            // Make sure we dont have a line outside bounds
            if ((x0 > xmax && x1 > xmax) || (x0 < xmin && x1 < xmin)) {
                // Illegal value(s)
                return nil
            }
            
            if x0 > xmax {
                x0 = xmax
                y0 = (segment.equation.c - x0)/segment.equation.b
            }
            else if x0 < xmin {
                x0 = xmin
                y0 = (segment.equation.c - x0)/segment.equation.b
            }
            
            if x1 > xmax {
                x1 = xmax
                y1 = (segment.equation.c - x1)/segment.equation.b
            }
            else if x1 < xmin {
                x1 = xmin
                y1 = (segment.equation.c - x1)/segment.equation.b
            }
            
            return Line(p0: CGPoint(x: x0, y: y0), p1: CGPoint(x: x1, y: y1))
        }
        else { // b == 1 (see Lineswift)
            // x0
            var x0 = xmin
            if let p = p0 {
                if p.x > xmin {
                    x0 = p.x
                }
                if x0 > xmax {
                    // Illegal Value
                    return nil
                }
            }
            
            // Ax + 1.0y = c
            // -> y = c - Ax
            var y0 = segment.equation.c - segment.equation.a*x0
            
            
            // x1
            var x1 = xmax
            if let p = p1 {
                if p.x < xmax {
                    x1 = p.x
                }
            }
            if x1 < xmin {
                // Illegal Value
                return nil
            }
            
            // Ax + 1.0y = c
            // -> y = c - Ax
            var y1 = segment.equation.c - segment.equation.a*x1
            
            // Make sure we dont have a line outside bounds
            if ((y0 > ymax && y1 > ymax) || (y0 < ymin && y1 < ymin)) {
                // Illegal value(s)
                return nil
            }
            
            
            if y0 > ymax {
                y0 = ymax
                x0 = (segment.equation.c - y0)/segment.equation.a
            }
            else if y0 < ymin {
                y0 = ymin
                x0 = (segment.equation.c - y0)/segment.equation.a
            }
            
            if y1 > ymax {
                y1 = ymax
                x1 = (segment.equation.c - y1)/segment.equation.a
            }
            else if y1 < ymin {
                y1 = ymin
                x1 = (segment.equation.c - y1)/segment.equation.a
            }
            
            return Line(p0: CGPoint(x: x0, y: y0), p1: CGPoint(x: x1, y: y1))
        }
    }
}

/// Vertices of the polygon needs to be arranged in a CCW fashion.
/// Ie: the Line[i].p1 == Line[i+1].p0 all the way to Line[n].p1 == Line[0].p0
public struct ConvexPolygon : BoundaryType {
    public let edges: [Line]
    
    public init(rect: CGRect) {
        let bottomLeft = rect.origin
        let bottomRight = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y)
        let topRight = CGPoint(x: bottomRight.x, y: rect.origin.y + rect.size.height)
        let topLeft = CGPoint(x: rect.origin.x, y: topRight.y)
        edges = [
            Line(p0: bottomLeft, p1: bottomRight),
            Line(p0: bottomRight, p1: topRight),
            Line(p0: topRight, p1: topLeft),
            Line(p0: topLeft, p1: bottomLeft)
        ]
        
        maximumBounds = rect
    }
    
    /// Vertices will be traversed in a CCW fashion, creating a Line between vertices[i] and vertices[i+1]
    /// all the way to the last line between vertices[n] and vertices[0].
    /// The resulting polygon is required to be convex.
    /// Note: Neighter convexitivity or CCW is enforced.
    public init(vertices: [CGPoint]) {
        if vertices.count == 0 {
            edges = []
            maximumBounds = CGRectZero
        }
        else {
            var lines: [Line] = []
            for i in 0..<vertices.count {
                if i < (vertices.count - 1) {
                    lines.append(Line(p0: vertices[i], p1: vertices[i+1]))
                }
                else {
                    lines.append(Line(p0: vertices[i], p1: vertices[0]))
                }
            }
            
            let xsort = vertices.sort{ $0.x < $1.x }
            let ysort = vertices.sort{ $0.y < $1.y }
            let xmin = xsort.first!.x
            let ymin = ysort.first!.y
            let xmax = xsort.last!.x
            let ymax = ysort.last!.y
            
            maximumBounds = CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
            edges = lines
        }
    }
    
    private let maximumBounds: CGRect
    /*private var maximumBounds: CGRect {
    guard edges.count > 0 else { return CGRectZero }
    let xmin = edges.map{ $0.p0.x < $0.p1.x ? $0.p0.x : $0.p1.x }.minElement()!
    let ymin = edges.map{ $0.p0.y < $0.p1.y ? $0.p0.y : $0.p1.y }.minElement()!
    let xmax = edges.map{ $0.p0.x > $0.p1.x ? $0.p0.x : $0.p1.x }.maxElement()!
    let ymax = edges.map{ $0.p0.y > $0.p1.y ? $0.p0.y : $0.p1.y }.maxElement()!
    
    return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
    }*/
    
    private let parallelEpsilon: CGFloat = 1.0E-10
    public func clipVertices(segment: Segment) -> Line? {
        guard let line = maximumBounds.clipVertices(segment) else { return nil }
        
        guard line.p0 != line.p1 else {
            // This is a point. Check if this point is within the polygon
            /*if p0.inside(polygon) {
            return self
            }*/
            return nil
        }
        
        var te: CGFloat = 0          // maximum entering segment parameter
        var tl: CGFloat = 1          // minimum entering segment parameter
        let ds = line.p1-line.p0  // direction vector of segment
        
        for edge in edges {
            let e = edge.p1-edge.p0
            let n = e.perp(line.p0-edge.p0)
            let d = -e.perp(ds)
            if fabs(d) < parallelEpsilon {
                if n < 0 {
                    // Segment is nearly parallel with edge and s.p0 is outside the edge
                    // so the segment is outside the polygon
                    return nil
                }
                else {
                    // Ignore this edge
                    continue
                }
            }
            
            let t = n/d
            if d < 0 { // Segment is entering across edge
                if t > te { // Update max
                    te = t
                    if te > tl {
                        return nil
                    } // Segment enters after leaving the polygon
                }
            }
            else {      // Segment is leaving across edge
                if t < tl { // Update min leaving
                    tl = t
                    if tl < te {
                        return nil
                    } // Segment leaves before entering the polygon
                }
            }
            
        }
        
        // te <= tl implies that there is a valid intersection subsegment
        return Line(p0: line.p0 + ds*Float(te), p1: line.p0 + ds*Float(tl))
    }
    
    public func contains(point: CGPoint) -> Bool {
        var crossingNumber = 0
        for edge in edges {
            if (edge.p0.y <= point.y && edge.p1.y > point.y) || (edge.p0.y > point.y && edge.p1.y <= point.y) {
                // upward crossing || downward crossing
                let ray = (point.y - edge.p0.y)/(edge.p1.y - edge.p0.y)
                if point.x < edge.p0.x + ray * (edge.p1.x - edge.p0.x) {
                    crossingNumber += 1
                }
            }
        }
        return (crossingNumber % 2 == 0 ? false : true)
    }
}