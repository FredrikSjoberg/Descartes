//
//  Edge.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

public class Edge {
//    internal let index: UInt
    internal unowned let leftSite: Site
    internal unowned let rightSite: Site
    
    internal let equation: LineEquation
    
    // If one of the Vertices are nil, the edge extends to infinity
    private var vertices: (left: CGPoint?, right: CGPoint?)
    internal var leftVertex: CGPoint? {
        return vertices.left
    }
    internal var rightVertex: CGPoint? {
        return vertices.right
    }
    // These are the actual vertices after processing
    internal var clippedVertices: (left: CGPoint, right: CGPoint)?
    internal var visible: Bool {
        return clippedVertices != nil
    }
    
/*    init(left: Site, right: Site, index: UInt) {
        self.index = index*/
    init(left: Site, right: Site) {
        leftSite = left
        rightSite = right
        
        equation = LineEquation(p0: leftSite.point, p1: rightSite.point)
        
        leftSite.addEdge(self)
        rightSite.addEdge(self)
    }
}

internal extension Edge {
    internal func setVertex(vertex: CGPoint, orientation: Orientation) {
        if orientation == .Left { vertices.left = vertex }
        else if orientation == .Right { vertices.right = vertex }
    }
}

internal extension Edge {
    internal func site(orientation: Orientation) -> Site {
        switch orientation {
        case .Left: return leftSite
        case .Right: return rightSite
        }
    }
}

internal extension Edge {
    internal func clipVertices(rect: CGRect) {
        func determinePoints() -> (v0: CGPoint?, v1: CGPoint?) {
            if equation.a == 1 && equation.b >= 0 {
                return (self.rightVertex, self.leftVertex)
            }
            else {
                return (self.leftVertex, self.rightVertex)
            }
        }
        
        let vertices = determinePoints()
        
        let result = equation.clipVertices(point0: vertices.v0, point1: vertices.v1, rect: rect)
        
        if let clipped = result {
            if equation.a == 1 && equation.b >= 0 {
                clippedVertices = (left: clipped.v0, right: clipped.v1)
            }
            else {
                clippedVertices = (left: clipped.v1, right: clipped.v0)
            }
        }
    }
}

internal extension Edge {
    internal var dualGraph: Node {
        return Node(delaunay: delaunayLine, voronoi: voronoiEdge)
    }
    
    internal var delaunayLine: Line {
        return Line(p0: leftSite.point, p1: rightSite.point)
    }
    
    internal var voronoiEdge: Line? {
        if let vertices = clippedVertices {
            if !CGPointEqualToPoint(vertices.left, vertices.right) {
                return Line(p0: vertices.left, p1: vertices.right)
            }
        }
        return nil
    }
}