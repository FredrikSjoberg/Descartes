//
//  GLKVector2+Internal.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import GLKit

internal extension GLKVector2 {
    internal var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}