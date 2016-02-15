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
    private let sites: [Site]
    private let locations: [CGPoint : Site]
    private var currentIndex = 0
    
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
        
        sites = arr.sort{ $0.point.compareYThenX($1.point) }
        locations = dict
        currentIndex = 0
        
        let bounds = CGRect(x: 0, y: 0, width: 2048, height: 2048)
        sites.forEach{
            print("\(bounds.contains($0.point)) : \($0.point)")
        }
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
    
    internal var xbounds: (min: CGFloat, delta: CGFloat) {
        let t = sites.map{ $0.point.x }
        let min = t.minElement()!
        let max = t.maxElement()!
        return (min, max-min)
    }
}

extension SiteList {
    internal var count: Int {
        return sites.count
    }
    
    internal func containsSite(point: CGPoint) -> Bool {
        return site(point) != nil
    }
    
    internal func site(point: CGPoint) -> Site? {
        return locations[point]
    }
}