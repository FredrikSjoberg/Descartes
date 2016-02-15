//
//  Site.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

class Site : Equatable {
    internal let point: CGPoint
    
    internal var edges: [Edge] = []
    
    init(point: CGPoint) {
        self.point = point
    }
    
    internal var region: Set<CGPoint> {
        var set = Set<CGPoint>()
        for e in edges {
            if let vertices = e.clippedVertices {
                set.insert(vertices.v0)
                set.insert(vertices.v1)
            }
        }
        return set
    }
}

func == (lhs: Site, rhs: Site) -> Bool {
    return lhs === rhs
}