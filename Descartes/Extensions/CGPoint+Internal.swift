//
//  CGPoint+Internal.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal extension CGPoint {
    internal init(x: Float, y: Float) {
        self.init(x: CGFloat(x),y: CGFloat(y))
    }
}

internal extension CGPoint {
    internal var normalized: CGPoint {
        let s = 1/sqrt(self.x*self.x + self.y*self.y)
        return CGPoint(x: self.x*s, y: self.y*s)
    }
    
    internal func distance(point: CGPoint) -> Float {
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
    internal func compareYThenX(point: CGPoint) -> Bool {
        return CGPoint.compareYThenX(self, point1: point)
    }
}

extension CGPoint : Hashable {
    public var hashValue: Int {
        // iOS Swift Game Development Cookbook
        // https://books.google.se/books?id=QQY_CQAAQBAJ&pg=PA304&lpg=PA304&dq=swift+CGpoint+hashvalue&source=bl&ots=1hp2Fph274&sig=LvT36RXAmNcr8Ethwrmpt1ynMjY&hl=sv&sa=X&ved=0CCoQ6AEwAWoVChMIu9mc4IrnxgIVxXxyCh3CSwSU#v=onepage&q=swift%20CGpoint%20hashvalue&f=false
        return x.hashValue << 32 ^ y.hashValue
    }
}

extension CGPoint : Equatable { }
public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return CGPointEqualToPoint(lhs, rhs)
}

internal func * (point: CGPoint, value: Float) -> CGPoint {
    return CGPoint(x: point.x*CGFloat(value), y: point.y*CGFloat(value))
}