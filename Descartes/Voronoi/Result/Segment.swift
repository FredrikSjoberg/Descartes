//
//  Segment.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/02/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import CoreGraphics

/// TODO: Switch names Segment<->Line to match conventions of a fixed vs unbounded (possibly) "line"
/// https://www.khanacademy.org/math/basic-geo/basic-geo-lines/basic-geo-lines-rays-angles/v/lines-line-segments-and-rays
public struct Segment {
    public let p0: CGPoint?
    public let p1: CGPoint?
    public let equation: LineEquation
    
    public init(p0: CGPoint?, p1: CGPoint?, equation: LineEquation) {
        self.p0 = p0
        self.p1 = p1
        self.equation = equation
    }
}
