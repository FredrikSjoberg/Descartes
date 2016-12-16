//
//  CGPoint+Internal.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal extension CGPoint {
    internal init(x: Float, y: Float) {
        self.init(x: CGFloat(x),y: CGFloat(y))
    }
}

internal extension CGPoint {
    internal var normalized: CGPoint {
        guard x != 0 && y != 0 else { return CGPoint.zero }
        let s = 1/sqrt(self.x*self.x + self.y*self.y)
        return CGPoint(x: self.x*s, y: self.y*s)
    }
    
    internal func distance(to point: CGPoint) -> Float {
        let dx = Float(self.x - point.x)
        let dy = Float(self.y - point.y)
        return sqrt((dx * dx) + (dy * dy))
    }
    
    internal static func compareYThenX(point0: CGPoint, point1: CGPoint) -> Bool {
        if point0.y < point1.y { return true }
        if point0.y > point1.y { return false }
        if point0.x < point1.x { return true }
        if point0.x > point1.x { return false }
        return true
    }
    
    internal func compareYThenX(with point: CGPoint) -> Bool {
        return CGPoint.compareYThenX(point0: self, point1: point)
    }
    
    internal func dot(point: CGPoint) -> CGFloat {
        return x*point.x + y*point.y
    }
    
    internal func cross(point: CGPoint) -> CGFloat {
        return x*point.y - y*point.x
    }
}

extension CGPoint {
    internal func colinear(with line: Line) -> Bool {
        let ab = line.vector
        let ac = line.p1-self
        return ab.cross(point: ac) == 0
    }
    
    fileprivate var epsilon: CGFloat {
        return 0.01
    }
    internal func on(line: Line) -> Bool {
        let ab = line.vector
        let ac = line.p1-self
        guard abs(ab.cross(point: ac)) < epsilon else { return false }
        
        let kac = ac.dot(point: ab)
        if kac < 0 { return false }
        if kac == 0 { return true } // Conincide with extremepoint
        let kab = ab.dot(point: ab)
        if kac > kab { return false }
        if kac == kab { return true } // Conincide with extremepoint
        return true // On line
    }
}

extension CGPoint : Hashable {
    public var hashValue: Int {
        // iOS Swift Game Development Cookbook
        // https://books.google.se/books?id=QQY_CQAAQBAJ&pg=PA304&lpg=PA304&dq=swift+CGpoint+hashvalue&source=bl&ots=1hp2Fph274&sig=LvT36RXAmNcr8Ethwrmpt1ynMjY&hl=sv&sa=X&ved=0CCoQ6AEwAWoVChMIu9mc4IrnxgIVxXxyCh3CSwSU#v=onepage&q=swift%20CGpoint%20hashvalue&f=false
        return x.hashValue << 32 ^ y.hashValue
    }
}

internal func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.distance(to: rhs) < 0.000001 //CGPointEqualToPoint(lhs, rhs)
}

internal func * (point: CGPoint, value: Float) -> CGPoint {
    return CGPoint(x: point.x*CGFloat(value), y: point.y*CGFloat(value))
}


internal func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
}

internal func + (lhs: CGPoint, rhs: Float) -> CGPoint {
    return CGPoint(x: lhs.x+CGFloat(rhs), y: lhs.y+CGFloat(rhs))
}

internal func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
}
