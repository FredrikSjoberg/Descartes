//
//  Heap.swift
//  KFDataStructures
//
//  Created by Fredrik Sjöberg on 24/09/15.
//  Copyright © 2015 Fredrik Sjoberg. All rights reserved.
//

import Foundation

internal struct Heap<Element: Equatable> {
    internal let comparator: (Element, Element) -> Bool
    fileprivate var contents: [Element]
    
    internal var isEmpty: Bool {
        return contents.isEmpty
    }
    
    internal func contains(element: Element) -> Bool {
        return contents.contains(element)
    }
    
    internal init(comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
        contents = []
    }
    
    internal init(comparator: @escaping (Element, Element) -> Bool, contents: [Element]) {
        self.comparator = comparator
        self.contents = []
        contents.forEach{ push(element: $0) }
    }
}

extension Heap {
    fileprivate mutating func swimHeap(index: Int) {
        var i = index
        while i > 0 {
            let parent = (i - 1) >> 1
            if comparator(contents[parent], contents[i]) {
                break
            }
            
            swap(&contents[parent], &contents[i])
            
            i = parent
        }
    }
    
    fileprivate mutating func sinkHeap(index: Int) {
        let left = index * 2 + 1
        let right = index * 2 + 2
        var smallest = index
        
        let count = contents.count
        
        if left < count && comparator(contents[left], contents[smallest]) {
            smallest = left
        }
        if right < count && comparator(contents[right], contents[smallest]) {
            smallest = right
        }
        if smallest != index {
            swap(&contents[index], &contents[smallest])
            sinkHeap(index: smallest)
        }
    }
}

extension Heap : DynamicQueueType {
    mutating func push(element: Element) {
        contents.append(element)
        
        guard contents.count > 1 else { return }
        swimHeap(index: contents.count - 1)
    }
    
    mutating func pop() -> Element? {
        guard !contents.isEmpty else { return nil }
        if contents.count == 1 { return contents.removeFirst() }
        
        swap(&contents[0], &contents[contents.endIndex - 1])
        let pop = contents.removeLast()
        sinkHeap(index: 0)
        return pop
    }
    
    func peek() -> Element? {
        return contents.first
    }
    
    mutating func invalidate(element: Element) {
        guard !contents.isEmpty else { return }
        guard let index = contents.index(of: element) else { return }
        let endIndex = contents.endIndex - 1
        guard index != endIndex else {
            // Bugfix! fatal error: swapping a location with itself is not supported
            contents.removeLast()
            return
        }
        
        swap(&contents[index], &contents[endIndex])
        contents.removeLast()
        sinkHeap(index: index)
    }
}

extension Heap : HeapType { }

extension Heap : CustomStringConvertible, CustomDebugStringConvertible {
    var description: String { return contents.description }
    var debugDescription: String { return contents.debugDescription }
}
