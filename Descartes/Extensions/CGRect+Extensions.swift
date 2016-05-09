//
//  CGRect+Extensions.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 17/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

public func / (lhs: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: lhs.width/scalar, height: lhs.height/scalar)
}

public func > (lhs: CGSize, rhs: CGSize) -> Bool {
    return lhs.height > rhs.height && lhs.width > rhs.width
}

extension CGRect {
    public var bottomLeft: CGPoint {
        return origin
    }
    
    public var bottomRight: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y)
    }
    
    public var topRight: CGPoint {
        return CGPoint(x: bottomRight.x, y: origin.y + size.height)
    }
    
    public var topLeft: CGPoint {
        return CGPoint(x: origin.x, y: topRight.y)
    }
    
    /// Returns the corners in clockwise order
    public var cornerPoints: [CGPoint] {
        return [bottomLeft, topLeft, topRight, bottomRight]
    }
}

extension CGRect {
    var bottomEdge: Line {
        return Line(p0: bottomLeft, p1: bottomRight)
    }
    var rightEdge: Line {
        return Line(p0: bottomRight, p1: topRight)
    }
    var topEdge: Line {
        return Line(p0: topRight, p1: topLeft)
    }
    var leftEdge: Line {
        return Line(p0: topLeft, p1: bottomLeft)
    }
}

extension CGRect {
    func intersects(lines: [Line]) -> Bool {
        return lines.map{ intersects($0) != nil }.reduce(false) {
            (sum, next) in
            return sum || next
        }
    }
}

extension CGRect {
    /**
     Splits a CGRect into scaled down but aspect preserved versions of self by recursion. Any subdivisions with 'size' larger than 'minSize' that also intersects 'lines' will be recursivley split.
    
     - parameters:
        - lines: Lines to check possible intersections with
        - minSize: Defines the size upon where recursion stops. (should match self's aspect ratio
        - increaseDepth: 'true' will do one final subdivision after minSize has been reached. 'false' will end once 'minSize' of subdivion has be reached
     
     - returns:
     An array of subdivided, aspect preserved rectangles matching the intersections with supplied lines.
    */
    public func splitIntersect(lines: [Line], minSize: CGSize, increaseDepth: Bool = false) -> [CGRect] {
        guard intersects(lines) else { return [self] }
        if quarterSize > minSize {
            return quarternize().flatMap{ $0.splitIntersect(lines, minSize: minSize, increaseDepth: increaseDepth) }
        }
        else if increaseDepth {
            return quarternize()
        }
        return [self]
    }
    
    /**
     'size' width and height divided by 2, in other words a quarter of the original 'size'
    */
    var quarterSize: CGSize {
        return size/2
    }
    
    /**
     Splits 'self' into 4 equally sized rectangles, split by lines at 'width'/2 and 'height'/2
     
     - returns:
     4 equally sized rectangles, split by lines at 'width'/2 and 'height'/2
    */
    func quarternize() -> [CGRect] {
        return [
            CGRect(origin: origin, size: quarterSize),
            CGRect(origin: CGPoint(x: origin.x, y: origin.y+quarterSize.height), size: quarterSize),
            CGRect(origin: CGPoint(x: origin.x+quarterSize.width, y: origin.y+quarterSize.height), size: quarterSize),
            CGRect(origin: CGPoint(x: origin.x+quarterSize.width, y: origin.y), size: quarterSize)
        ]
    }
}