//
//  TableTests.swift
//  Descartes
//
//  Created by Fredrik Sjöberg on 16/12/16.
//  Copyright © 2016 Fredrik Sjoberg. All rights reserved.
//

import Foundation
import Nimble
import Quick
@testable import Descartes

class TableSpec: QuickSpec {
    override func spec() {
        describe("init") {
            it("should initialize correctly") {
                let table = Table(value: 1)
                expect(table).notTo(beNil())
            }
        }
    }
}
