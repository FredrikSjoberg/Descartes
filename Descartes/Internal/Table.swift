//
//  Table.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal struct Table {
    internal let b0: Int
    internal let b1: Int
    internal let r0: Float
    internal let r1: Float
    
    init(value: Float) {
        let t = value + Float(N)
        b0 = Int(t) & BM
        b1 = (b0+1) & BM
        r0 = t - Float(Int(t))
        r1 = r0 - 1
    }
}