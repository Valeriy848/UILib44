//
//  UILib44Tests.swift
//  UILib44Tests
//
//  Created by Valeriy on 02.03.2022.
//

import XCTest
@testable import UILib44

class TestColors: XCTestCase {

    func testAllColorsCount() throws {
        XCTAssertEqual(13, CustomColors.allColors.count)
    }
}
