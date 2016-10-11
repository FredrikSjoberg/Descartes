//
//  Int+Internal.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 20/07/15.
//  Copyright (c) 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal extension Int {
    func clamp (_ min: Int, _ max: Int) -> Int {
        return Swift.max(min, Swift.min(max, self))
    }
}
