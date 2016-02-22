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
    private let eventQueue: EventQueue
    private let beachLine: BeachLine
    private let siteList: SiteList
    private var edges: [Edge] = []
    private var halfedges: [Halfedge] = []
    private let bottomMostSite: Site!
    
    public let boundary: BoundaryType
    
    public init(points: [CGPoint], boundary: BoundaryType) {
        let validPoints = points.filter{ boundary.contains($0) }
        self.boundary = boundary
        siteList = SiteList(points: validPoints)
        eventQueue = EventQueue()
        beachLine = BeachLine()
        
        if siteList.count > 0 {
            bottomMostSite = siteList.pop()!
            
            // Run the algorithm
            fortunesAlgorithm()
        }
        else {
            // TODO: Slightly better than simply unwrapping, but not good!
            bottomMostSite = nil
        }
    }
    
    private func fortunesAlgorithm() {
        // We now have an initial structure set up.
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
        
        edges.forEach{ $0.clipVertices(boundary) }
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
    
    /// Returns a ConvexPolygon with edges surrounding the site (including boundary edges if any), or nil if no site is found.
    public func cellAt(point: CGPoint) -> ConvexPolygon? {
        guard boundary.contains(point) else { return nil }
        guard let site = siteList.site(point) else { return nil }
        
        let voronoiEdges = site.edges.flatMap{ $0.voronoiEdge }
        var queue = voronoiEdges
        
        // No edges? Single site means it's border is the boundary
        guard queue.count > 0 else { return ConvexPolygon(lines: boundary.borders) }
        
        // Sort them in CCW order
        var result: [Line] = [queue.popLast()!]
        while !queue.isEmpty {
            let first = result.first!.p0
            let last = result.last!.p1
            
            for line in queue {
                let index = queue.indexOf(line)!
                
                if last == line.p0 {
                    result.append(line)
                    queue.removeAtIndex(index)
                }
                else if last == line.p1 {
                    result.append(Line(p0: line.p1, p1: line.p0))
                    queue.removeAtIndex(index)
                }
                else if first == line.p1 {
                    result.insert(line, atIndex: 0)
                    queue.removeAtIndex(index)
                }
                else if first == line.p0 {
                    result.insert(Line(p0: line.p1, p1: line.p0), atIndex: 0)
                    queue.removeAtIndex(index)
                }
            }
        }
        
        let firstEdge = result.first!
        let lastEdge = result.last!
        
        let firstIntersection = firstEdge.p0
        let lastIntersection = lastEdge.p1
        
        guard let firstBorder = boundary.pointOnBorder(firstIntersection)
            ,let lastBorder = boundary.pointOnBorder(lastIntersection) else { return ConvexPolygon(lines: result) }
        
        guard firstBorder != lastBorder else {
            result.append(Line(p0: lastIntersection, p1: firstIntersection))
            return ConvexPolygon(lines: result)
        }
        
        let sitePoint = site.point
        let l0 = Line(p0: sitePoint, p1: lastBorder.p0)
        let l1 = Line(p0: sitePoint, p1: lastBorder.p1)
        
        let t0 = voronoiEdges.reduce(false){ $0 || $1.intersects(l0) }
        let t1 = voronoiEdges.reduce(false){ $0 || $1.intersects(l1) }
        if !t0 {
            result.append(Line(p0: lastIntersection, p1: lastBorder.p0))
        }
        if !t1 {
            result.append(Line(p0: lastIntersection, p1: lastBorder.p1))
        }
        
        /*
        if !lastEdge.intersects(l0) {
        result.append(Line(p0: lastIntersection, p1: lastBorder.p0))
        }
        if !lastEdge.intersects(l1) {
        result.append(Line(p0: lastIntersection, p1: lastBorder.p1))
        }*/
        
        let f0 = Line(p0: sitePoint, p1: firstBorder.p0)
        let f1 = Line(p0: sitePoint, p1: firstBorder.p1)
        
        let g0 = voronoiEdges.reduce(false){ $0 || $1.intersects(f0) }
        let g1 = voronoiEdges.reduce(false){ $0 || $1.intersects(f1) }
        if !g0 {
            result.insert(Line(p0: firstBorder.p0, p1: firstIntersection), atIndex: 0)
        }
        if !g1 {
            result.insert(Line(p0: firstBorder.p1, p1: firstIntersection), atIndex: 0)
        }
        /*if !firstEdge.intersects(f0) {
        result.insert(Line(p0: firstBorder.p0, p1: firstIntersection), atIndex: 0)
        }
        if !firstEdge.intersects(f1) {
        result.insert(Line(p0: firstBorder.p1, p1: firstIntersection), atIndex: 0)
        }*/
        
        queue = boundary.borders.filter{ $0 != lastBorder && $0 != firstBorder }
        
        queue.forEach{
            let first = result.first!.p0
            let last = result.last!.p1
            
            if last == $0.p0 {
                result.append($0)
            }
            else if last == $0.p1 {
                result.append(Line(p0: $0.p1, p1: $0.p0))
            }
            else if first == $0.p1 {
                result.insert($0, atIndex: 0)
            }
            else if first == $0.p0 {
                result.insert(Line(p0: $0.p1, p1: $0.p0), atIndex: 0)
            }
        }
        
        return ConvexPolygon(lines: result)
    }
}