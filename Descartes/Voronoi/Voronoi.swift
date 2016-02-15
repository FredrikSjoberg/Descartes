//
//  Voronoi.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

public class Voronoi {
    let eventQueue: EventQueue
    let beachLine: BeachLine
    let siteList: SiteList
    var edges: [Edge] = []
    var halfedges: [Halfedge] = []
    let bottomMostSite: Site
    
    let bounds: CGRect
    public init(points: [CGPoint], bounds: CGRect) {
        self.bounds = bounds
        siteList = SiteList(points: points)
        eventQueue = EventQueue()
        
        let xbounds = siteList.xbounds
        let siteCount = sqrtf(Float(siteList.count)+4)
        beachLine = BeachLine(xmin: xbounds.min, xdelta: xbounds.delta, size: Int(siteCount))
        
        bottomMostSite = siteList.pop()! // TODO: Implicit unwrapping is terrible!
        
        // Run the algorithm
        fortunesAlgorithm()
    }
    
    internal func fortunesAlgorithm() {
        // We now have an initial structure set up.
        // The third event to follow will also be a circleEvent.
        // From now on we might generate intersections
        // Note: the eventQueue is still empty, as no intersections have been possible yet
        while true {
            let nextSite = siteList.peek()?.point
            let nextCircle = eventQueue.minPoint
            
            if let sitePoint = nextSite, let circlePoint = nextCircle {
                
                if sitePoint.compareYThenX(circlePoint) {
                    // Site Event
                    processSiteEvent()
                }
                else {
                    // Circle Event
                    processCircleEvent()
                }
            }
            else if nextSite != nil {
                // Site Event
                processSiteEvent()
            }
            else if nextCircle != nil {
                // Circle Event
                processCircleEvent()
            }
            else {
                // Nothing left in siteList or eventQueue, we are done
                break
            }
        }
        
        edges.forEach{ $0.clipVertices(bounds) }
    }
    
    /// Adds halfedges to the beachline
    private func processSiteEvent() {
        if let newSite = siteList.pop() {
            let lbnd = beachLine.leftNeighbor(newSite.point)
            // Found a leftNeighbor, process as usual
            let rbnd = lbnd.right
            
            let bottomSite = (lbnd.edge == nil ? bottomMostSite : lbnd.edge!.site(lbnd.orientation!.opposite)) // TODO: Implicit unwrapping is terrible!
            
            let edge = Edge(left: bottomSite, right: newSite)
            edges.append(edge)
            
            let bisector0 = Halfedge(edge: edge, orientation: .Left)
            halfedges.append(bisector0)
            beachLine.insert(bisector0, rightOf: lbnd)
            
            if let vertex = lbnd.intersects(bisector0) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: newSite)
                eventQueue.remove(lbnd)
                eventQueue.insert(lbnd, withIntersection: intersection)
            }
            
            let bisector1 = Halfedge(edge: edge, orientation: .Right)
            halfedges.append(bisector1)
            beachLine.insert(bisector1, rightOf: bisector0)
            
            if let vertex = rbnd?.intersects(bisector1) {
                let intersecton = TransformedVertex(vertex: vertex, relativeTo: newSite)
                eventQueue.insert(bisector1, withIntersection: intersecton)
            }
        }
    }
    
    /// Removes halfedges from the beachline
    /// Consider sites (s-1, s, s+1) forming a site event E (ie an intersection of 2 halfedges) in the event queue.
    /// Processing the event amounts to removing the 2 halfedges from the beachline and creating a new breakpoint (tracing out a new edge) from (s-1, s+1).
    /// Finaly, we need to check if the new halfedge intersects with any halfedges to the left or right.
    private func processCircleEvent() {
        if let lbnd = eventQueue.pop() {
            // The point is required to exist here. We cant add a halfedge to the eventQueue without specifying an intersectionVertex
            let point = lbnd.intersectionVertex!.actualPoint
            
            let rbnd = lbnd.right
            let llbnd = lbnd.left!
            let rrbnd = rbnd?.right
            
            let bSite = (lbnd.edge == nil ? bottomMostSite : lbnd.edge!.site(lbnd.orientation!))
            let tSite = (rbnd?.edge == nil ? bottomMostSite : rbnd!.edge!.site(rbnd!.orientation!.opposite))
            
            lbnd.edge?.setVertex(point, orientation: lbnd.orientation!)
            
            if let rbnd = rbnd {
                rbnd.edge?.setVertex(point, orientation: rbnd.orientation!)
                eventQueue.remove(rbnd)
                beachLine.remove(rbnd)
            }
            beachLine.remove(lbnd)
            
            let bottomSite = (bSite.point.y > tSite.point.y ? tSite : bSite)
            let topSite = (bottomSite == bSite ? tSite : bSite)
            let orientation = (bottomSite == bSite ? Orientation.Left : Orientation.Right)
            
            let edge = Edge(left: bottomSite, right: topSite)
            edges.append(edge)
            
            let bisector = Halfedge(edge: edge, orientation: orientation)
            halfedges.append(bisector)
            beachLine.insert(bisector, rightOf: llbnd)
            edge.setVertex(point, orientation: orientation.opposite)
            
            if let vertex = llbnd.intersects(bisector) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: bottomSite)
                eventQueue.remove(llbnd)
                eventQueue.insert(llbnd, withIntersection: intersection)
            }
            
            if let vertex = rrbnd?.intersects(bisector) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: bottomSite)
                eventQueue.insert(bisector, withIntersection: intersection)
            }
        }
    }
}

public extension Voronoi {
    // Returns the dual representation
    public var dualGraph: [Node] {
        return edges.map{ $0.dualGraph }
    }
    
    public var voronoiEdges: [Line] {
        return edges.flatMap{ $0.voronoiEdge }
    }
    
    public var delaunayLines: [Line] {
        return edges.map{ $0.delaunayLine }
    }
    
    public func region(point: CGPoint) -> Set<CGPoint> {
        if let site = siteList.site(point) {
            return site.region
        }
        return Set()
    }
}