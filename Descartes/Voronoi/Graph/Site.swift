//
//  Site.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

public class Site {
    private var edges:[Edge] = []
    
    public let point: CGPoint
    
    init(point: CGPoint) {
        self.point = point
    }
}

internal extension Site {
    internal static func compareYThenX(site0: Site, site1: Site) -> Bool {
        if site0.point.y < site1.point.y { return true }
        if site0.point.y > site1.point.y { return false }
        if site0.point.x < site1.point.x { return true }
        if site0.point.x > site1.point.x { return false }
        return false
    }
    
    internal func addEdge(edge: Edge) {
        edges.append(edge)
    }
}

internal extension Site {
    internal var region: Set<CGPoint> {
        var set = Set<CGPoint>()
        for e in edges {
            if let vertices = e.clippedVertices {
                set.insert(vertices.left)
                set.insert(vertices.right)
            }
        }
        return set
    }
}

extension Site : Hashable {
    public var hashValue: Int {
        return point.hashValue
    }
}

extension Site : Equatable { }
public func ==(lhs: Site, rhs: Site) -> Bool {
    return lhs === rhs
}