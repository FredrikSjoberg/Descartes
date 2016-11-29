//
//  Orientation.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-18.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal enum Orientation {
    case left
    case right
    
    internal var opposite: Orientation {
        switch self {
        case .left: return .right
        case .right: return .left
        }
    }
}
