//
//  Beachline.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 02/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

internal class BeachLine {
    private var leftEnd: Halfedge
    private var rightEnd: Halfedge
    private var hash: [Halfedge?]
    
    private let xmin: CGFloat
    private let xdelta: CGFloat
    private let hashSize: Int
    
    internal init(xmin: CGFloat, xdelta: CGFloat, size: Int) {
        self.xmin = xmin
        self.xdelta = xdelta
        hashSize = 2*size
        
        hash = Array(count: hashSize, repeatedValue: nil)
        leftEnd = Halfedge.dummy()
        rightEnd = Halfedge.dummy()
        leftEnd.right = rightEnd
        rightEnd.left = leftEnd
        hash[0] = leftEnd
        hash[hash.count-1] = rightEnd
    }
    
    private func getHash(value: Int) -> Halfedge? {
        guard value >= 0 && value < hashSize else {
            return nil
        }
        
        return hash[value]
    }
    
    internal func insert(halfedge: Halfedge, rightOf right: Halfedge) {
        halfedge.left = right
        halfedge.right = right.right
        right.right?.left = halfedge
        right.right = halfedge
    }
    
    internal func remove(halfedge: Halfedge) {
        halfedge.left?.right = halfedge.right
        halfedge.right?.left = halfedge.left
        
        halfedge.left = nil
        halfedge.right = nil
    }
    
    internal func leftNeighbor(point: CGPoint) -> Halfedge {
        /*let bucket = Int( (point.x - xmin)/xdelta * CGFloat(hashSize) )
        
        let b = bucket.clamp(0, hashSize-1)
        var halfedge = getHash(b)
        */
        
        var current = leftEnd
        while current != rightEnd && current.isLeftOf(point) {
            if current.right != nil {
                current = current.right!
            }
        }
        
        if current.left != nil {
            return current.left!
        }
        return leftEnd
    }
}