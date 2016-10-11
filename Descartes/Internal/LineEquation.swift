//
//  Lineswift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-18.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

public struct LineEquation {
    
    // format: ax + by = c
    public let a: CGFloat
    public let b: CGFloat
    public let c: CGFloat
    
    /// Creates a Perpendicular line to the points p0 and p1, halfway between them
    public init(p0: CGPoint, p1: CGPoint) {
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        
        let c = p0.x*dx + p0.y*dy + (dx*dx + dy*dy)/2
        if abs(dx) > abs(dy) {
            a = 1.0
            b = dy/dx
            self.c = c/dx
        }
        else {
            b = 1.0
            a = dx/dy
            self.c = c/dy
        }
    }
    
    public func determinant(with eq: LineEquation) -> CGFloat {
        return (self.a * eq.b - self.b * eq.a)
    }
    
    // Lines are parallel if their determinant does not deviate more than some value (parallelEpsilon)
    fileprivate let parallelEpsilon: CGFloat = 1.0E-10
    public func isParallel(to eq: LineEquation) -> Bool {
        let det = determinant(with: eq)
        return (-parallelEpsilon < det && det < parallelEpsilon)
    }
    
    public func intersects(eq: LineEquation) -> CGPoint? {
        if isParallel(to: eq) { return nil }
        let det = determinant(with: eq)
        let xIntersect = (c * eq.b - eq.c * b)/det
        let yIntersect = (eq.c * a - c * eq.a)/det
        return CGPoint(x: xIntersect, y: yIntersect)
    }
}
/*
internal extension LineEquation {
    /*
    To generalize this into a polygon BoundingBox instead of a rectangle
    we need to have line-equations/edges that define the bounds.
    
    Y
    ^
    1.0 *             * ii(0.5,1)
    |            ----   \
    |        ----        \
    0.7 *   * i(0,0.7)    \
    |        \             \
    0.5 *     \             * iii(0.7,0.5)
    |          \        ----
    |           \   ----
    0.2 *         * iv(0.3,0.2)
    |
    0.0 *
    --+-*-------*----*-----*-------*- >X
    |0.0     0.3  0.5   0.7     1.0
    
    LineI   : i->ii
    LineII  : ii->iii
    LineIII : iii->iv
    LineIV  : iv->i
    
    xMin: dependant on LineIV(y=[0.2,0.7]) and LineI(y=[0.7,1])
    xMax: dependant on LineIII(y=[0.2,0.5]) and LineII(y=[0.5,1])
    
    yMin: dependant on LineIV(x=[0,0.3]) and LineIII(x=[0.3,0.7])
    yMax: dependant on LineI(x=[0,0.5]) and LineII(x=[0.5,0.7])
    
    */
    internal func clipVertices(point0 point0: CGPoint?, point1: CGPoint?, rect: CGRect) -> Line? {
        let p0 = point0
        let p1 = point1
        
        let xmin = CGRectGetMinX(rect)
        let xmax = CGRectGetMaxX(rect)
        let ymin = CGRectGetMinY(rect)
        let ymax = CGRectGetMaxY(rect)
        
        // Ax + By = c
        // -> x = (c - By)/A
        if a == 1 {
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
            var x0 = c - b*y0
            
            
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
            var x1 = c - b*y1
            
            // Make sure we dont have a line outside bounds
            if ((x0 > xmax && x1 > xmax) || (x0 < xmin && x1 < xmin)) {
                // Illegal value(s)
                return nil
            }
            
            if x0 > xmax {
                x0 = xmax
                y0 = (c - x0)/b
            }
            else if x0 < xmin {
                x0 = xmin
                y0 = (c - x0)/b
            }
            
            if x1 > xmax {
                x1 = xmax
                y1 = (c - x1)/b
            }
            else if x1 < xmin {
                x1 = xmin
                y1 = (c - x1)/b
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
            var y0 = c - a*x0
            
            
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
            var y1 = c - a*x1
            
            // Make sure we dont have a line outside bounds
            if ((y0 > ymax && y1 > ymax) || (y0 < ymin && y1 < ymin)) {
                // Illegal value(s)
                return nil
            }
            
            
            if y0 > ymax {
                y0 = ymax
                x0 = (c - y0)/a
            }
            else if y0 < ymin {
                y0 = ymin
                x0 = (c - y0)/a
            }
            
            if y1 > ymax {
                y1 = ymax
                x1 = (c - y1)/a
            }
            else if y1 < ymin {
                y1 = ymin
                x1 = (c - y1)/a
            }
            
            return Line(p0: CGPoint(x: x0, y: y0), p1: CGPoint(x: x1, y: y1))
        }
    }
}*/
