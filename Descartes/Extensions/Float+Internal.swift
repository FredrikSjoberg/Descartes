//
//  Float+Internal.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal extension Float {
    internal var sCurve: Float {
        return (self * self * (3 - 2*self))
    }
}

internal extension Float {
    internal func lerp(a a: Float, b: Float) -> Float {
        return (a + self*(b - a))
    }
}