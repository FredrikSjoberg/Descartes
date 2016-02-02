//
//  HalfedgePriorityQueue.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-18.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal struct HalfedgePriorityQueue {
    private let ymin: Float
    private let ymax: Float
    
    private let hashSize: Int
    private var hash: [Halfedge?]
    private var count: Int = 0
    private var minBucket: Int = 0
    
    init(bounds: CGRect, numSites num: Int) {
        ymin = Float(bounds.origin.y)
        ymax = Float(bounds.size.height)
        
        hashSize = 4 * Int(sqrt(Float(num + 4)))
        hash = [Halfedge?](count: hashSize, repeatedValue: Halfedge.seed())
    }
    
    private func emptyAt(bucket: Int) -> Bool {
        return (hash[bucket]?.next == nil)
    }
    
    private mutating func adjustMinBucket() {
        while (minBucket < (hashSize - 1) && emptyAt(minBucket)) {
            ++minBucket
        }
    }
    
    private func bucket(halfedge: Halfedge) -> Int {
        let bucket = Int((Float(halfedge.transformedPoint.y) - ymin) / ymax) * hashSize
        return bucket.clamp(0, hashSize-1)
    }
}

internal extension HalfedgePriorityQueue {
    internal mutating func insert(halfedge: Halfedge) {
        let index = bucket(halfedge)
        
        if index < minBucket { minBucket = index }
        
        var previous = hash[index]
        var next = previous?.next
        while next != nil && (halfedge.transformedPoint.y > next!.transformedPoint.y || (halfedge.transformedPoint.y == next!.transformedPoint.y && halfedge.transformedPoint.x > next!.transformedPoint.x)) {
            previous = next
            next = previous?.next
        }
        
        halfedge.next = previous?.next
        previous?.next = halfedge
        count++
    }
    
    internal mutating func remove(halfedge: Halfedge) {
        let index = bucket(halfedge)
        
        if halfedge.actualPoint != nil {
            var previous = hash[index]
            while previous?.next !== halfedge {
                previous = previous?.next
            }
            
            previous?.next = halfedge.next
            halfedge.next = nil
            count--
        }
    }
    
    internal mutating func pop() -> Halfedge? {
        if let halfedge = hash[minBucket],
            let result = halfedge.next {
                halfedge.next = result.next
                result.next = nil
                count--
                return result
        }
        return nil
    }
    
    internal mutating func minPoint() -> CGPoint? {
        adjustMinBucket()
        return hash[minBucket]?.next?.transformedPoint
    }
    
    internal var empty: Bool {
        return (count == 0)
    }
}