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
    fileprivate var leftEnd: Halfedge
    fileprivate var rightEnd: Halfedge
    
    internal init() {
        leftEnd = Halfedge.dummy()
        rightEnd = Halfedge.dummy()
        leftEnd.right = rightEnd
        rightEnd.left = leftEnd
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
    
    internal func leftNeighbor(for point: CGPoint) -> Halfedge {
        var current = leftEnd
        while current != rightEnd && current.isLeft(of: point) {
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
