//
//  VoronoiTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class VoronoiTests: QuickSpec {
    override func spec() {
        let bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        describe("init") {
            let regionPoint = CGPoint(x: 1, y: 1)
            let middlePoint = CGPoint(x: 3, y: 6)
            let outOfBounds = CGPoint(x: 11, y: 11)
            let points = [
                regionPoint,
                CGPoint(x: 2, y: 3),
                middlePoint,
                CGPoint(x: 2, y: 8),
                CGPoint(x: 1, y: 9),
                
                CGPoint(x: 6, y: 1),
                CGPoint(x: 8, y: 3),
                CGPoint(x: 9, y: 7),
                
                ]
            it("should init properly") {
                let improper = Voronoi(points: [], boundary: bounds)
                expect(improper.dualGraph).to(haveCount(0))
                
                let outside = Voronoi(points: [outOfBounds], boundary: bounds)
                expect(outside.dualGraph).to(haveCount(0))
            }
            
            let voronoi = Voronoi(points: points, boundary: bounds)
            
            it("should process and create graph") {
                expect(voronoi.dualGraph.count) > 0
                expect(voronoi.voronoiEdges.count) > 0
                expect(voronoi.delaunayLines.count) > 0
            }
            
            let nonSitePoint = CGPoint(x: 1, y: 2)
            it("should manage regions") {
                expect(voronoi.region(point: regionPoint).count) > 0
                
                expect(voronoi.region(point: nonSitePoint)).to(haveCount(0))
            }
            
            it("should generate cell for sitePoint") {
                expect(voronoi.cell(at: regionPoint)).toNot(beNil())
                expect(voronoi.cell(at: middlePoint)).toNot(beNil())
            }
            
            it("should not generate cells for non site points inside bounds") {
                expect(voronoi.cell(at: nonSitePoint)).to(beNil())
            }
            
            it("should not generate cells for points outside bounds") {
                expect(voronoi.cell(at: outOfBounds)).to(beNil())
            }
            
            it("should generate border as cell for single cell Voronoi") {
                let singleSite = Voronoi(points: [regionPoint], boundary: bounds)
                expect(singleSite.cell(at: regionPoint)).toNot(beNil())
            }
            
        }
    }
}
