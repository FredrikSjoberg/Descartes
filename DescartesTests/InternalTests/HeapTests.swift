//
//  HeapTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class HeapTests: QuickSpec {
    override func spec() {
        var heap: Heap<Int>!
        
        beforeEach {
            heap = Heap(comparator: { $0 < $1 }, contents: [2, 0, 1])
        }
        describe("init") {
            it("should initialize with comparator") {
                let emptyHeap:Heap<Int> = Heap{ $0 < $1 }
                expect(emptyHeap.isEmpty).to(beTrue())
                
                let raw = [2, 0, 1].sorted(by: emptyHeap.comparator)
                let sorted = [0, 1, 2]
                expect(raw) == sorted
            }
            
            it("should initialize and sort contents, remove them on pop") {
                (0..<3).forEach{ index -> Void in
                    let value = heap.pop()
                    expect(value).toNot(beNil())
                    expect(value!) == index
                }
                
                expect(heap.isEmpty).to(beTrue())
            }
        }
        
        describe("Contents") {
            it("should contain added elements") {
                expect(heap.contains(element: 1)).to(beTrue())
            }
            
            it("should return but not remove elements on peek") {
                let checkFor = 0
                expect(heap.contains(element: checkFor)).to(beTrue())
                let value = heap.peek()
                expect(value).toNot(beNil())
                expect(value!) == checkFor
                expect(heap.contains(element: checkFor)).to(beTrue())
            }
            
            it("should return nil on empty heap") {
                var emptyHeap:Heap<Int> = Heap{ $0 < $1 }
                expect(emptyHeap.pop()).to(beNil())
            }
        }
        
        describe("Push") {
            it("should preserve order on push") {
                heap.push(element: 4)
                heap.push(element: 3)
                (0...4).forEach{ index in
                    let value = heap.pop()
                    expect(value).toNot(beNil())
                    expect(value!) == index
                }
                
                expect(heap.isEmpty).to(beTrue())
            }
        }
        
        describe("Invalidate") {
            it("should invalidate objects correctly") {
                let notFound = 10
                heap.invalidate(element: notFound)
                heap.invalidate(element: 2)
                heap.invalidate(element: 0)
                heap.invalidate(element: 1)
                expect(heap.isEmpty).to(beTrue())
                let emptyInvalidation = 10
                heap.invalidate(element: emptyInvalidation)
                expect(heap.isEmpty).to(beTrue())
            }
        }
        
        describe("CustomStringConvertible, CustomDebugStringConvertible") {
            it("should display heapStructure as description") {
                let list = [0, 2, 1]
                expect(heap.description) == list.description
                expect(heap.debugDescription) == list.debugDescription
            }
        }
    }
}
