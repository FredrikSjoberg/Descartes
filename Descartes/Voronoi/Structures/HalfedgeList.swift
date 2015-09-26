//
//  HalfedgeList.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-17.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

internal struct HalfedgeList {
    private let xmin: Float
    private let xmax: Float
    
    private let hashSize: Int
    private var hash: [Halfedge?]
    private var deletedQueue: [Halfedge] = []
    
    private var leftEnd: Halfedge
    private var rightEnd: Halfedge
    
    init(bounds: CGRect, numSites num: Int) {
        xmin = Float(bounds.origin.x)
        xmax = Float(bounds.size.width)
        
        hashSize = 2 * Int(sqrt(Float(num + 4)))
        hash = [Halfedge?](count: hashSize, repeatedValue: nil)
        
        leftEnd = Halfedge.seed()
        rightEnd = Halfedge.seed()
        
        leftEnd.rightNeighbor = rightEnd
        rightEnd.leftNeighbor = leftEnd
        
        hash[0] = leftEnd
        hash[hashSize-1] = rightEnd
    }
    
    // Search the hash for a matching Halfedge while also patching when deleted halfedges are found
    private mutating func getHash(bucket: Int) -> Halfedge? {
        if bucket < 0 || bucket >= hashSize {
            return nil
        }
        
        if let halfedge = hash[bucket] {
            if deletedQueue.contains(halfedge) {
                hash[bucket] = nil
                return nil
            }
            return halfedge
        }
        return nil
    }
}

internal extension HalfedgeList {
    internal mutating func leftNeighbor(point: CGPoint) -> Halfedge {
        // Get close to the desired halfedge using the hash
        var index = bucket(point)
        
        var halfedge = getHash(index)
        if halfedge == nil {
            // If no Halfedge was found, search forward and backwards for a first occurence
            var up = index + 1
            var down = index - 1
            while halfedge == nil {
                if down > 0 {
                    if let he = getHash(down) {
                        halfedge = he
                        index = down
                        break
                    }
                    else { down-- }
                }
                
                if up < hashSize {
                    if let he = getHash(up) {
                        halfedge = he
                        index = up
                        break
                    }
                    else { up++ }
                }
                
                if up == hashSize && down == 0 {
                    print("Warning: leftNeighbor:\(point) | Unable to find a halfEdge in the hash")
                    // Unable to find a halfEdge in the hash
                    break
                }
            }
        }
        
        // Do a linear search of the hash for the matching halfedge
        if var result = halfedge {
            if result == leftEnd || (result != rightEnd && result.isLeftOf(point)) {
                // Right
                while result != rightEnd && result.isLeftOf(point) {
                    if let next = result.rightNeighbor { result = next }
                    else { break }
                }
                if let next = result.leftNeighbor { result = next }
                else { print("Note: Linear search leftNeighbor is nil") }
            }
            else {
                // Left
                while result != leftEnd && !result.isLeftOf(point) {
                    if let next = result.leftNeighbor { result = next }
                    else { break }
                }
            }
            
            // Updating the hash table
            if index > 0 && index < (hashSize-1) {
                hash[index] = result
            }
            return result
        }
        
        assert(halfedge != nil, "ASSERT Warning: leftNeighbor:\(point) | Unable to find a halfEdge in the hash")
        return halfedge!
    }
    
    private func bucket(point: CGPoint) -> Int {
        let bucket = Int((Float(point.x) - xmin) / xmax) * hashSize
        return bucket.clamp(0, hashSize-1)
    }
}

internal extension HalfedgeList {
    // Insert halfedge to the right of reference
    internal mutating func insert(halfedge: Halfedge, rightOf right: Halfedge) {
        halfedge.leftNeighbor = right
        halfedge.rightNeighbor = right.rightNeighbor
        right.rightNeighbor?.leftNeighbor = halfedge
        right.rightNeighbor = halfedge
    }
    
    // Removes the halfedge from the left-right list
    internal mutating func remove(halfedge: Halfedge) {
        halfedge.leftNeighbor?.rightNeighbor = halfedge.rightNeighbor
        halfedge.rightNeighbor?.leftNeighbor = halfedge.leftNeighbor
        
        deletedQueue.append(halfedge)
        
        halfedge.leftNeighbor = nil
        halfedge.rightNeighbor = nil
    }
}

