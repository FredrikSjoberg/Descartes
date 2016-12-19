//
//  SiteTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class SiteTests: QuickSpec {
    override func spec() {
        var site: Site!
        
        beforeEach {
            site = Site(point: CGPoint.zero)
        }
        
        describe("init") {
            it("should initialize properly") {
                expect(site.point) == CGPoint.zero
                expect(site.edges.count) == 0
                expect(site.region.count) == 0
            }
        }
        
        describe("Region") {
            it("should not have a region before edges are clipped") {
                expect(site.region.count) == 0
            }
            
            it("should return region when edges are clipped") {
                let site1 = Site(point: CGPoint(x: 10, y: 10))
                let edge = Edge(left: site, right: site1)
                let bounds = CGRect(x: 2, y: 2, width: 6, height: 6)
                edge.clipVertices(by: bounds)
                let expected:Set<CGPoint> = [CGPoint(x: 8, y: 2), CGPoint(x: 2, y: 8)]
                expect(site.region) == expected
            }
        }
    }
}
