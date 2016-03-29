//
//  HeapType.swift
//  KFDataStructures
//
//  Created by Fredrik Sjöberg on 24/09/15.
//  Copyright © 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal protocol HeapType {
    associatedtype Element
    var comparator: (Element, Element) -> Bool { get }
}