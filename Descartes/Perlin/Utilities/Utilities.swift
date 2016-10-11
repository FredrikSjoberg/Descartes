//
//  Utilities.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal let perlinSampleSize = 1024

internal let B = perlinSampleSize
internal let BM = perlinSampleSize-1

internal let N = 0x1000
internal let NP = 12 // 2^N
internal let NM = 0xfff

internal let doubleBplus2 = perlinSampleSize + perlinSampleSize + 2

internal var generateRandom: Float {
    return Float((Int(arc4random()) % (B + B)) - B) / Float(B)
}
