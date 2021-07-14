//
//  QuantityTests.swift
//  
//
//  Created by Don Willems on 07/07/2021.
//

import XCTest
@testable import CoreMeasure

final class QuantityTests: XCTestCase {
    
    func testNormalisedAngle() {
        let lon1 = try? Longitude(1.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon1)
        XCTAssertEqual(lon1!.scalarValue, 1.5 * .pi)
        let lon2 = try? Longitude(3.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon2)
        XCTAssertNotEqual(lon2!.scalarValue, 3.5 * .pi)
        XCTAssertEqual(lon2!.scalarValue, 1.5 * .pi)
        let lon3 = try? Longitude(-0.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon3)
        XCTAssertNotEqual(lon3!.scalarValue, -0.5 * .pi)
        XCTAssertEqual(lon3!, lon1!)
        let lon4 = try? Longitude(-2.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon4)
        XCTAssertNotEqual(lon4!.scalarValue, -2.5 * .pi)
        XCTAssertEqual(lon4!, lon1!)
        
        let lon5 = try? Longitude(-4.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon5)
        XCTAssertEqual(lon5!, lon1!)
    }
}
