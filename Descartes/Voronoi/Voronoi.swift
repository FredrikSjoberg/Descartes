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
    fileprivate let eventQueue: EventQueue
    fileprivate let beachLine: BeachLine
    fileprivate let siteList: SiteList
    fileprivate var edges: [Edge] = []
    fileprivate var halfedges: [Halfedge] = []
    fileprivate let bottomMostSite: Site!
    
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
    
    fileprivate func fortunesAlgorithm() {
        // We now have an initial structure set up.
        // From now on we might generate intersections
        // Note: the eventQueue is still empty, as no intersections have been possible yet
        while true {
            let nextSite = siteList.peek()?.point
            let nextCircle = eventQueue.minPoint
            
            if let sitePoint = nextSite, let circlePoint = nextCircle {
                
                if sitePoint.compareYThenX(with: circlePoint) {
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
        
        edges.forEach{ $0.clipVertices(by: boundary) }
    }
    
    /// Adds halfedges to the beachline
    fileprivate func processSiteEvent() {
        if let newSite = siteList.pop() {
            let lbnd = beachLine.leftNeighbor(for: newSite.point)
            // Found a leftNeighbor, process as usual
            let rbnd = lbnd.right
            
            let bottomSite = (lbnd.edge == nil ? bottomMostSite! : lbnd.edge!.site(with: lbnd.orientation!.opposite)) // TODO: Implicit unwrapping is terrible!
            
            let edge = Edge(left: bottomSite, right: newSite)
            edges.append(edge)
            
            let bisector0 = Halfedge(edge: edge, orientation: .left)
            halfedges.append(bisector0)
            beachLine.insert(halfedge: bisector0, rightOf: lbnd)
            
            if let vertex = lbnd.intersects(other: bisector0) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: newSite)
                eventQueue.remove(halfedge: lbnd)
                eventQueue.insert(halfedge: lbnd, withIntersection: intersection)
            }
            
            let bisector1 = Halfedge(edge: edge, orientation: .right)
            halfedges.append(bisector1)
            beachLine.insert(halfedge: bisector1, rightOf: bisector0)
            
            if let vertex = rbnd?.intersects(other: bisector1) {
                let intersecton = TransformedVertex(vertex: vertex, relativeTo: newSite)
                eventQueue.insert(halfedge: bisector1, withIntersection: intersecton)
            }
        }
    }
    
    /// Removes halfedges from the beachline
    /// Consider sites (s-1, s, s+1) forming a site event E (ie an intersection of 2 halfedges) in the event queue.
    /// Processing the event amounts to removing the 2 halfedges from the beachline and creating a new breakpoint (tracing out a new edge) from (s-1, s+1).
    /// Finaly, we need to check if the new halfedge intersects with any halfedges to the left or right.
    fileprivate func processCircleEvent() {
        if let lbnd = eventQueue.pop() {
            // The point is required to exist here. We cant add a halfedge to the eventQueue without specifying an intersectionVertex
            let point = lbnd.intersectionVertex!.actualPoint
            
            let rbnd = lbnd.right
            let llbnd = lbnd.left!
            let rrbnd = rbnd?.right
            
            let bSite = (lbnd.edge == nil ? bottomMostSite! : lbnd.edge!.site(with: lbnd.orientation!))
            let tSite = (rbnd?.edge == nil ? bottomMostSite! : rbnd!.edge!.site(with: rbnd!.orientation!.opposite))
            
            lbnd.edge?.set(vertex: point, with: lbnd.orientation!)
            
            if let rbnd = rbnd {
                rbnd.edge?.set(vertex: point, with: rbnd.orientation!)
                eventQueue.remove(halfedge: rbnd)
                beachLine.remove(halfedge: rbnd)
            }
            beachLine.remove(halfedge: lbnd)
            
            let bottomSite = (bSite.point.y > tSite.point.y ? tSite : bSite)
            let topSite = (bottomSite == bSite ? tSite : bSite)
            let orientation = (bottomSite == bSite ? Orientation.left : Orientation.right)
            
            let edge = Edge(left: bottomSite, right: topSite)
            edges.append(edge)
            
            let bisector = Halfedge(edge: edge, orientation: orientation)
            halfedges.append(bisector)
            beachLine.insert(halfedge: bisector, rightOf: llbnd)
            edge.set(vertex: point, with: orientation.opposite)
            
            if let vertex = llbnd.intersects(other: bisector) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: bottomSite)
                eventQueue.remove(halfedge: llbnd)
                eventQueue.insert(halfedge: llbnd, withIntersection: intersection)
            }
            
            if let vertex = rrbnd?.intersects(other: bisector) {
                let intersection = TransformedVertex(vertex: vertex, relativeTo: bottomSite)
                eventQueue.insert(halfedge: bisector, withIntersection: intersection)
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
        if let site = siteList.site(at: point) {
            return site.region
        }
        return Set()
    }
    
    fileprivate struct BorderIntersection {
        let border: Line
        let atPoint: CGPoint
        let edge: Line
        
        init(border: Line, atPoint: CGPoint, byLine: Line) {
            self.border = border
            self.atPoint = atPoint
            edge = byLine
        }
        
        
    }
    
    fileprivate func borderPath(for site: Site) -> [(raw: Line, intersected: Line)]? {
        let voronoiEdges = site.edges.flatMap{ $0.voronoiEdge }
        
        var intersections: [BorderIntersection] = []
        boundary.borders.forEach{ b in
            voronoiEdges.forEach{
                if $0.p0.on(line: b) {
                    intersections.append(BorderIntersection(border: b, atPoint: $0.p0, byLine: $0))
                }
                
                if $0.p1.on(line: b) {
                    intersections.append(BorderIntersection(border: b, atPoint: $0.p1, byLine: $0))
                }
            }
        }
        
        var borderLines: [(raw: Line, intersected: Line)] = []
        boundary.borders.forEach{ b in
            let merged = intersections.filter{ $0.border == b }
            
            if merged.count == 1 {
                let intersection = merged.first!
                let sitePoint = site.point
                let l0 = Line(p0: sitePoint, p1: intersection.border.p0)
                let l1 = Line(p0: sitePoint, p1: intersection.border.p1)
                
                let t0 = voronoiEdges.reduce(true){ $0 && !$1.intersects(line: l0) }
                let t1 = voronoiEdges.reduce(true){ $0 && !$1.intersects(line: l1) }
                
                if t0 {
                    borderLines.append((intersection.border, Line(p0: intersection.atPoint, p1: intersection.border.p0)))
                }
                if t1 {
                    borderLines.append((intersection.border, Line(p0: intersection.atPoint, p1: intersection.border.p1)))
                }
            }
            else if merged.count == 2 {
                let first = merged.first!
                let last = merged.last!
                
                borderLines.append((first.border, Line(p0: first.atPoint, p1: last.atPoint)))
            }
        }
        
        return borderLines
    }
    
    /// Returns a ConvexPolygon with edges surrounding the site (including boundary edges if any), or nil if no site is found.
    public func cell(at point: CGPoint) -> ConvexPolygon? {
        guard boundary.contains(point) else { return nil }
        guard let site = siteList.site(at: point) else { return nil }
        
        let voronoiEdges = site.edges.flatMap{ $0.voronoiEdge }
        var queue = voronoiEdges
        
        
        // No edges? Single site means it's border is the boundary
        guard queue.count > 0 else { return ConvexPolygon(lines: boundary.borders) }
        
        var remainingBorders = boundary.borders
        if let borderLines = borderPath(for: site) {
            let intersected = borderLines.map{ $0.intersected }
            let raw = borderLines.map{ $0.raw }
            
            raw.forEach{
                if let index = remainingBorders.index(of: $0) {
                    remainingBorders.remove(at: index)
                }
            }
            queue.append(contentsOf: intersected)
        }
        
        // Sort them in CCW order
        var result: [Line] = [queue.popLast()!]
        while !queue.isEmpty {
            let first = result.first!.p0
            let last = result.last!.p1
            
            for line in queue {
                let index = queue.index(of: line)!
                
                if last == line.p0 {
                    result.append(line)
                    queue.remove(at: index)
                }
                else if last == line.p1 {
                    result.append(Line(p0: line.p1, p1: line.p0))
                    queue.remove(at: index)
                }
                else if first == line.p1 {
                    result.insert(line, at: 0)
                    queue.remove(at: index)
                }
                else if first == line.p0 {
                    result.insert(Line(p0: line.p1, p1: line.p0), at: 0)
                    queue.remove(at: index)
                }
            }
        }
        
        remainingBorders.forEach{
            let first = result.first!.p0
            let last = result.last!.p1
            
            if last == $0.p0 {
                result.append($0)
            }
            else if last == $0.p1 {
                result.append(Line(p0: $0.p1, p1: $0.p0))
            }
            else if first == $0.p1 {
                result.insert($0, at: 0)
            }
            else if first == $0.p0 {
                result.insert(Line(p0: $0.p1, p1: $0.p0), at: 0)
            }
        }
        
        return ConvexPolygon(lines: result)
    }
}
