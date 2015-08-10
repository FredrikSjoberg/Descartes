//
//  Orientation.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 2015-07-18.
//  Copyright (c) 2015 FredrikSjoberg. All rights reserved.
//

import Foundation

internal enum Orientation {
    case Left
    case Right
    
    internal var opposite: Orientation {
        switch self {
        case let .Left: return .Right
        case let .Right: return .Left
        }
    }
}