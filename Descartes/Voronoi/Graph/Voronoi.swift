//
//  Voronoi.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

public class Voronoi {
    private var edges: [Edge] = []
    private var halfedges: [Halfedge] = []
    private var siteList: SiteList
    private var priorityQueue: HalfedgePriorityQueue
    private var halfedgeList: HalfedgeList // Stores the wavefront
    
    public let bounds: CGRect
    
    init(points: [CGPoint], bounds: CGRect) {
        self.bounds = bounds
        siteList = SiteList(points: points)
        
        let dataBounds = siteList.siteBounds()
        priorityQueue = HalfedgePriorityQueue(bounds: dataBounds, numSites: siteList.count)
        halfedgeList = HalfedgeList(bounds: dataBounds, numSites: siteList.count)
    }
}

internal extension Voronoi {
    private func fortunesAlgorithm() {
        if let bottomMostSite = siteList.next() {
            var newSite = siteList.next()
            
            while true {
                newSite = processSiteEvent(newSite)
                let circleEventProcessed = processCircleEvent()
                
                if newSite == nil && !circleEventProcessed {
                    // We are done
                    // No more siteList has sites to process AND priorityQueue is empty
                    break
                }
            }
        }
    }
    
    private func processSiteEvent(possibleSite: Site?) -> Site? {
        if let currentSite = possibleSite {
            if let voronoiMin = priorityQueue.minPoint() {
                if priorityQueue.empty || currentSite.point.compareYThenX(voronoiMin) {
                    // The current site is the smallest, begin processing
                    let lbnd0 = halfedgeList.leftNeighbor(currentSite.point)
                    let rbnd = lbnd0.rightNeighbor
                    
                    let bottomSite = rightRegion(lbnd0)
                    
                    let edge = Edge(left: bottomSite, right: currentSite)
                    edges.append(edge)
                    
                    let bisector0 = Halfedge(edge: edge, orientation: .Left)
                    halfedges.append(bisector0)
                    halfedgeList.insert(bisector0, rightOf: lbnd0)
                    
                    if let vertex = bisector0.intersect(lbnd0) {
                        priorityQueue.remove(lbnd0)
                        lbnd0.setVertex(vertex, relativeTo: currentSite)
                        priorityQueue.insert(lbnd0)
                    }
                    
                    
                    let lbnd1 = bisector0
                    let bisector1 = Halfedge(edge: edge, orientation: .Right)
                    halfedges.append(bisector1)
                    halfedgeList.insert(bisector1, rightOf: lbnd1)
                    
                    if let vertex = rbnd?.intersect(bisector1) {
                        bisector1.setVertex(vertex, relativeTo: currentSite)
                        priorityQueue.insert(bisector1)
                    }
                    
                    return siteList.next()
                }
            }
            
            // Site was not processed, return it
            return currentSite
        }
        // Nothing to process (ie possibleSite == nil)
        return possibleSite
    }
    
    typealias CircleEventProcessed = Bool
    private func processCircleEvent() -> CircleEventProcessed {
        if !priorityQueue.empty {
            // Intersection is smallest
            if let lbnd = priorityQueue.pop() {
                if let rbnd = lbnd.rightNeighbor {
                    if let v = lbnd.actualPoint {
                        lbnd.edge?.setVertex(v, orientation: lbnd.orientation)
                        rbnd.edge?.setVertex(v, orientation: rbnd.orientation)
                        
                        halfedgeList.remove(lbnd)
                        priorityQueue.remove(lbnd)
                        halfedgeList.remove(rbnd)
                        
                        if let llbnd = lbnd.leftNeighbor,
                            let rrbnd = rbnd.rightNeighbor {
                                let siteOrder = detemineTopBottom(rightRegion(rbnd), bottom: leftRegion(lbnd))
                                let orientation = siteOrder.orientation
                                let bottomSite = siteOrder.sites.bottom
                                let topSite = siteOrder.sites.top
                                
                                let edge = Edge(left: bottomSite, right: topSite)
                                edges.append(edge)
                                
                                let bisector = Halfedge(edge: edge, orientation: orientation)
                                halfedges.append(bisector)
                                halfedgeList.insert(bisector, rightOf: llbnd)
                                edge.setVertex(v, orientation: orientation.opposite)
                                
                                if let vertex = llbnd.intersect(bisector) {
                                    priorityQueue.remove(llbnd)
                                    llbnd.setVertex(vertex, relativeTo: bottomSite)
                                    priorityQueue.insert(llbnd)
                                }
                                
                                if let vertex = bisector.intersect(rrbnd) {
                                    bisector.setVertex(vertex, relativeTo: bottomSite)
                                    priorityQueue.insert(bisector)
                                }
                                
                                return true
                        }
                        else {
                            println("Warning: processCircleEvent: Halfedge(s) llbnd &&/|| rrbnd not found")
                        }
                    }
                    else {
                        println("Warning: processCircleEvent: lbnd has no actual point")
                    }
                }
                else {
                    println("Warning: processCircleEvent: rightNeighbor not found for lbnd")
                }
            }
            else {
                println("Warning: processCircleEvent: No halfedge to pop")
            }
        }
        return false
    }
    
    private func detemineTopBottom(top: Site, bottom: Site) -> (sites: (top: Site, bottom: Site), orientation: Orientation) {
        if bottom.point.y > top.point.y {
            return ((bottom, top), .Right)
        }
        else {
            return ((top, bottom), .Left)
        }
    }
    
    private func leftRegion(halfedge: Halfedge) -> Site {
        if let edge = halfedge.edge {
            return edge.site(halfedge.orientation)
        }
        else {
            return siteList.firstSite()
        }
    }
    
    private func rightRegion(halfedge: Halfedge) -> Site {
        if let edge = halfedge.edge {
            return edge.site(halfedge.orientation.opposite)
        }
        else {
            return siteList.firstSite()
        }
    }
}

public extension Voronoi {
    // Returns the dual representation 
    public var dualGraph: [Node] {
        var nodes = [Node]()
        for e in edges {
            nodes.append(e.dualGraph)
        }
        return nodes
    }
    
    public var voronoiEdges: [Line] {
        var lines = [Line]()
        for e in edges {
            if let line = e.voronoiEdge {
                lines.append(line)
            }
        }
        return lines
    }
    
    public var delaunayLines: [Line] {
        var lines = [Line]()
        for e in edges {
            lines.append(e.delaunayLine)
        }
        return lines
    }
    
    public func region(point: CGPoint) -> Set<CGPoint> {
        if let site = siteList.site(point) {
            return site.region
        }
        return Set()
    }
}

