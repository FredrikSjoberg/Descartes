//
//  SiteList.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

internal struct SiteList {
    private var sorted: Bool = false
    private var currentIndex: Int = 0
    
    private var locations: [CGPoint:Site] = [:]
    private var sites: [Site] = []
    
    init(points: [CGPoint]) {
        for i in 0..<points.count {
            let p = points[i]
            
            // TODO: Should we have some sort of Minimi Distance to distinguish points?
            // ie: one point is 0.1d away from present point, thus they are not Equal, but perhaps they should not be allowed to coexist anyway
            if locations[p] == nil {
                let site = Site(point: p)
                sites.append(site)
                locations[p] = site
            }
        }
    }
}

internal extension SiteList {
    private mutating func sort() {
        sites.sortInPlace{ Site.compareYThenX($0, site1: $1) }
        sorted = true
        currentIndex = 0
    }
    
    internal mutating func siteBounds() -> CGRect {
        if sites.count == 0 { return CGRectZero }
        
        if !sorted { sort() }
        
        let xmin = sites.map{ $0.point.x }.minElement()!
        let xmax = sites.map{ $0.point.x }.maxElement()!
        
        // Sites are allready sorted on y
        let ymin = sites[0].point.y
        let ymax = sites[sites.count-1].point.y
        
        return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
    }
}

internal extension SiteList {
    internal var count: Int {
        return sites.count
    }
    
    internal func containsSite(point: CGPoint) -> Bool {
        return site(point) != nil
    }
    
    internal func site(point: CGPoint) -> Site? {
        return locations[point]
    }
    
    internal mutating func next() -> Site? {
        if !sorted { sort() }
        
        if currentIndex < sites.count {
            return sites[currentIndex++]
        }
        return nil
    }
    
    internal mutating func firstSite() -> Site {
        assert(sites.count > 0, "Sites cant be zero")
        
        if !sorted {
            sort()
            currentIndex++
        }
        return sites[0]
    }
}