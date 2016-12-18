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
    
    fileprivate var _leftVertex: CGPoint?
    internal var leftVertex: CGPoint? {
        return _leftVertex
    }
    fileprivate var _rightVertex: CGPoint?
    internal var rightVertex: CGPoint? {
        return _rightVertex
    }
    
    // These are the actual vertices after processing
    internal var clippedVertices: Line?
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
    
    internal func site(with orientation: Orientation) -> Site {
        switch orientation {
        case .left: return leftSite
        case .right: return rightSite
        }
    }
    
    internal func set(vertex: CGPoint, with orientation: Orientation) {
        switch orientation {
        case .left: _leftVertex = vertex
        case .right: _rightVertex = vertex
        }
    }
    
    
    internal func clipVertices(by boundary: BoundaryType) {
        let vertices = (equation.a == 1 && equation.b >= 0 ? (rightVertex, leftVertex) : (leftVertex, rightVertex))
        
        let segment = Segment(p0: vertices.0, p1: vertices.1, equation: equation)
        clippedVertices = boundary.clipVertices(of: segment)
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
        guard let vertices = clippedVertices else { return nil }
        guard !vertices.p0.equalTo(vertices.p1) else { return nil }
        return Line(p0: vertices.p0, p1: vertices.p1)
    }
}
