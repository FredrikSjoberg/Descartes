//
//  CGRect+Extensions.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 17/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {
    var bottomLeft: CGPoint {
        return origin
    }
    
    var bottomRight: CGPoint {
        return CGPoint(x: origin.x + size.width, y: origin.y)
    }
    
    var topRight: CGPoint {
        return CGPoint(x: bottomRight.x, y: origin.y + size.height)
    }
    
    var topLeft: CGPoint {
        return CGPoint(x: origin.x, y: topRight.y)
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