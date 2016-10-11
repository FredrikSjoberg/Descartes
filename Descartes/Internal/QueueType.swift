//
//  QueueType.swift
//  KFDataStructures
//
//  Created by Fredrik Sjöberg on 24/09/15.
//  Copyright © 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal protocol QueueType {
    associatedtype Element
    
    mutating func push(element: Element)
    mutating func pop() -> Element?
    func peek() -> Element?
}

internal protocol DynamicQueueType : QueueType {
    mutating func invalidate(element: Element)
}
