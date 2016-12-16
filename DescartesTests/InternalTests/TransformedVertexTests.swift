//
//  TransformedVertexTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class TransformedVertexSpec: QuickSpec {
    override func spec() {
        let site = Site(point: CGPoint(x: 10, y: 10))
        let point = CGPoint(x: 10, y: 6)
        let distance:Float = sqrt(4*4)
        describe("init") {
            it("should calculate correct transformation for y coordinate in Voronoi space") {
                let vertex = TransformedVertex(vertex: point, relativeTo: site)
                
                let yStar = Float(point.y) + distance
                expect(vertex.yStar) == yStar
            }
        }
    }
}
