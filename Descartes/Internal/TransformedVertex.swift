//
//  TransformedVertex.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal struct TransformedVertex {
    internal let actualPoint: CGPoint
    
    // Vertex's y coordinate in transformed Voronoi V* space
    internal let yStar: Float
    
    internal init(vertex: CGPoint, relativeTo site: Site) {
        actualPoint = vertex
        yStar = Float(vertex.y) + vertex.distance(to: site.point)
    }
    
    internal var transformedPoint: CGPoint {
        return CGPoint(x: Float(actualPoint.x), y: yStar)
    }
}
