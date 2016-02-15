//
//  Edge.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

class Edge {
    internal unowned let rightSite: Site
    internal unowned let leftSite: Site
    
    internal let equation: LineEquation
    
    private var _leftVertex: CGPoint?
    internal var leftVertex: CGPoint? {
        return _leftVertex
    }
    private var _rightVertex: CGPoint?
    internal var rightVertex: CGPoint? {
        return _rightVertex
    }
    
    // These are the actual vertices after processing
    internal var clippedVertices: (v0: CGPoint, v1: CGPoint)?
    internal var visible: Bool {
        return clippedVertices != nil
    }
    
    init(left: Site, right: Site) {
        leftSite = left
        rightSite = right
        
        equation = LineEquation(p0: leftSite.point, p1: rightSite.point)
        
        leftSite.edges.append(self)
        rightSite.edges.append(self)
    }
    
    internal func site(orientation: Orientation) -> Site {
        switch orientation {
        case .Left: return leftSite
        case .Right: return rightSite
        }
    }
    
    internal func setVertex(vertex: CGPoint, orientation: Orientation) {
        switch orientation {
        case .Left: _leftVertex = vertex
        case .Right: _rightVertex = vertex
        }
    }
    
    
    internal func clipVertices(rect: CGRect) {
        let vertices = (equation.a == 1 && equation.b >= 0 ? (rightVertex, leftVertex) : (leftVertex, rightVertex))
        
        let result = equation.clipVertices(point0: vertices.0, point1: vertices.1, rect: rect)
        clippedVertices = result
    }
}

extension Edge {
    internal var dualGraph: Node {
        return Node(delaunay: delaunayLine, voronoi: voronoiEdge)
    }
    
    internal var delaunayLine: Line {
        return Line(p0: leftSite.point, p1: rightSite.point)
    }
    
    internal var voronoiEdge: Line? {
        if let vertices = clippedVertices {
            if !CGPointEqualToPoint(vertices.v0, vertices.v1) {
                return Line(p0: vertices.v0, p1: vertices.v1)
            }
        }
        return nil
    }
}