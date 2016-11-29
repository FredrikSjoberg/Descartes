//
//  SiteList.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal class SiteList {
    fileprivate let sites: [Site]
    fileprivate let locations: [CGPoint : Site]
    fileprivate var currentIndex = 0
    
    internal init(points: [CGPoint]) {
        var dict: [CGPoint : Site] = [:]
        var arr: [Site] = []
        
        // TODO: Should we have some sort of Minimi Distance to distinguish points?
        // ie: one point is 0.1d away from present point, thus they are not Equal, but perhaps they should not be allowed to coexist anyway
        points.forEach{
            if dict[$0] == nil {
                let site = Site(point: $0)
                dict[$0] = site
                arr.append(site)
            }
        }
        
        sites = arr.sorted{ $0.point.compareYThenX(with: $1.point) }
        locations = dict
        currentIndex = 0
    }
    
    internal func peek() -> Site? {
        guard currentIndex < sites.count else { return nil }
        return sites[currentIndex]
    }
    
    internal func pop() -> Site? {
        guard currentIndex < sites.count else { return nil }
        let site = sites[currentIndex]
        currentIndex += 1
        return site
    }
}

extension SiteList {
    internal var count: Int {
        return sites.count
    }
    
    internal func containsSite(point: CGPoint) -> Bool {
        return site(at: point) != nil
    }
    
    internal func site(at point: CGPoint) -> Site? {
        return locations[point]
    }
}
