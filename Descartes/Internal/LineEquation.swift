//
//  Lineswift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-18.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation
internal struct LineEquation {
    
    // format: ax + by = c
    internal let a: Float
    internal let b: Float
    internal let c: Float
    
    init(p0: CGPoint, p1: CGPoint) {
        let dx = p1.x - p0.x
        let dy = p1.y - p0.y
        
        let c = p0.x*dx + p0.y*dy + (dx*dx + dy*dy)/2
        if abs(dx) > abs(dy) {
            a = 1.0
            b = Float(dy/dx)
            self.c = Float(c/dx)
        }
        else {
            b = 1.0
            a = Float(dx/dy)
            self.c = Float(c/dy)
        }
    }
    
    internal func determinant(eq: LineEquation) -> Float {
        return (self.a * eq.b - self.b * eq.a)
    }
    
    // Lines are parallel if their determinant does not deviate more than some value (parallelEpsilon)
    private let parallelEpsilon: Float = 1.0E-10
    internal func isParallel(eq: LineEquation) -> Bool {
        let det = determinant(eq)
        return (-parallelEpsilon < det && det < parallelEpsilon)
    }
    
    internal func intersection(eq: LineEquation) -> CGPoint? {
        if isParallel(eq) { return nil }
        let det = determinant(eq)
        let xIntersect = (c * eq.b - eq.c * b)/det
        let yIntersect = (eq.c * a - c * eq.a)/det
        return CGPoint(x: xIntersect, y: yIntersect)
    }
}

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
    internal func clipVertices(#point0: CGPoint?, point1: CGPoint?, rect: CGRect) -> (v0: CGPoint, v1: CGPoint)? {
        struct Bounds {
            let xmin: Float
            let xmax: Float
            let ymin: Float
            let ymax: Float
            
            init(rect: CGRect) {
                xmin = Float(rect.origin.x)
                xmax = Float(rect.size.width)
                ymin = Float(rect.origin.y)
                ymax = Float(rect.size.height)
            }
        }
        
        struct Point {
            let x: Float
            let y: Float
            
            init(_ x: Float, _ y: Float) {
                self.x = x
                self.y = y
            }
            
            init?(_ cgPoint: CGPoint?) {
                if let p = cgPoint {
                    x = Float(p.x)
                    y = Float(p.y)
                }
                return nil
            }
        }
        
        let bounds = Bounds(rect: rect)
        let p0 = Point(point0)
        let p1 = Point(point1)
        
        // Ax + By = c
        // -> x = (c - By)/A
        if a == 1 {
            // y0
            var y0 = bounds.ymin
            if let p = p0 {
                if p.y > bounds.ymin {
                    y0 = p.y
                }
            }
            if y0 > bounds.ymax {
                // Illegal value
                return nil
            }
            
            // 1.0x + By = c
            // -> x = C - By
            var x0 = c - b*y0
            
            
            // y1
            var y1 = bounds.ymax
            if let p = p1 {
                if p.y < bounds.ymax {
                    y1 = p.y
                }
            }
            if y1 < bounds.ymin {
                // Illegal value
                return nil
            }
            
            // 1.0x + By = c
            // -> x = C - By
            var x1 = c - b*y1
            
            // Make sure we dont have a line outside bounds
            if ((x0 > bounds.xmax && x1 > bounds.xmax) || (x0 < bounds.xmin && x1 < bounds.xmin)) {
                // Illegal value(s)
                return nil
            }
            
            
            // Clip Coordinates
            func clipCoordinates(point: Point) -> CGPoint {
                if point.x > bounds.xmax {
                    return CGPoint(x: bounds.xmax, y: (c - point.x)/b)
                }
                else if point.x < bounds.xmin {
                    return CGPoint(x: bounds.xmin, y: (c - point.x)/b)
                }
                return CGPoint(x: point.x, y: point.y)
            }
            
            return (clipCoordinates(Point(x0, y0)), clipCoordinates(Point(x1, y1)))
        }
        else { // b == 1 (see Lineswift)
            // x0
            var x0 = bounds.xmin
            if let p = p0 {
                if p.x > bounds.xmin {
                    x0 = p.x
                }
                if x0 > bounds.xmax {
                    // Illegal Value
                    return nil
                }
            }
            
            // Ax + 1.0y = c
            // -> y = c - Ax
            var y0 = c - a*x0
            
            
            // x1
            var x1 = bounds.xmax
            if let p = p1 {
                if p.x < bounds.xmax {
                    x1 = p.x
                }
            }
            if x1 < bounds.xmin {
                // Illegal Value
                return nil
            }
            
            // Ax + 1.0y = c
            // -> y = c - Ax
            var y1 = c - a*x1
            
            // Make sure we dont have a line outside bounds
            if ((y0 > bounds.ymax && y1 > bounds.ymax) || (y0 < bounds.ymin && y1 < bounds.ymin)) {
                // Illegal value(s)
                return nil
            }
            
            // Clip Coordinates
            func clipCoordinates(point: Point) -> CGPoint {
                if point.y > bounds.ymax {
                    return CGPoint(x: (c - point.y)/b, y: bounds.ymax)
                }
                else if point.x < bounds.xmin {
                    return CGPoint(x: (c - point.y)/b, y: bounds.ymin)
                }
                return CGPoint(x: point.x, y: point.y)
            }
            
            return (clipCoordinates(Point(x0, y0)), clipCoordinates(Point(x1, y1)))
        }
    }
    
}