//
//  SiteListTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 19/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class SiteListTests: QuickSpec {
    override func spec() {
        var list: SiteList!
        var sorted: [CGPoint]!
        beforeEach {
            let points = [
                CGPoint.zero,
                CGPoint(x: 0, y: 10),
                CGPoint(x: 10, y: 10),
                CGPoint(x: 10, y: 0)
                ]
            
            sorted = points.sorted{ $0.compareYThenX(with: $1) }
            list = SiteList(points: points)
        }
        
        describe("init") {
            it("should initialize properly") {
                expect(list.count) == 4
            }
            
            it("should contain site") {
                expect(list.containsSite(point: CGPoint.zero)) == true
                expect(list.site(at: CGPoint.zero)).toNot(beNil())
            }
        }
        
        
        describe("Peek and Pop") {
            it("should peek sites without removing them") {
                let peeked = list.peek()
                expect(peeked).toNot(beNil())
                expect(peeked!.point) == sorted.first!
                
                let secondPeek = list.peek()
                expect(secondPeek).toNot(beNil())
                expect(secondPeek!) == peeked!
            }
            
            it("should pop sites in order") {
                (0..<4).forEach{ index in
                    let popped = list.pop()
                    expect(popped).toNot(beNil())
                    expect(popped!.point) == sorted[index]
                }
                
                expect(list.peek()).to(beNil())
                expect(list.pop()).to(beNil())
            }
        }
    }
}
