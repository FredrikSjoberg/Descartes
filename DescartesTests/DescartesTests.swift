//
//  DescartesTests.swift
//  DescartesTests
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import XCTest

class DescartesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

import Nimble
import Quick
class LineSpec: QuickSpec {
    override func spec() {
        describe("Line") {
            it("is true") {
                let first = true
                let second = false
                let third = true
                
                expect(first) == true
                expect(second) == true
            }
        }
    }
}
