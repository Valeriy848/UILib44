//
//  TestIcons.swift
//  UILib44Tests
//
//  Created by Valeriy on 02.03.2022.
//

import XCTest
@testable import UILib44

class TestIcons: XCTestCase {

    func testAllIconsCount() throws {
        XCTAssertEqual(7, CustomIcons.allImages.count)
    }
}
