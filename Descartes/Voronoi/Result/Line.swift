//
//  Line.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Line {
    public let p0: CGPoint
    public let p1: CGPoint
    
    init(p0: CGPoint, p1: CGPoint) {
        self.p0 = p0
        self.p1 = p1
    }
}