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
        let lonM1 = Measure(1.5 * .pi, unit: .radian)
        let lon1 = try? Longitude(lonM1)
        XCTAssertNotNil(lon1)
        XCTAssertEqual(lon1!.value, lonM1)
        let lonM2 = Measure(3.5 * .pi, unit: .radian)
        let lon2 = try? Longitude(lonM2)
        XCTAssertNotNil(lon2)
        XCTAssertNotEqual(lon2!.value, lonM2)
        XCTAssertEqual(lon2!.value, lonM1)
        let lonM3 = Measure(-0.5 * .pi, unit: .radian)
        let lon3 = try? Longitude(lonM3)
        XCTAssertNotNil(lon3)
        XCTAssertNotEqual(lon3!.value, lonM3)
        XCTAssertEqual(lon3!.value, lonM1)
        let lonM4 = Measure(-2.5 * .pi, unit: .radian)
        let lon4 = try? Longitude(lonM4)
        XCTAssertNotNil(lon4)
        XCTAssertNotEqual(lon4!.value, lonM4)
        XCTAssertEqual(lon4!.value, lonM1)
        
        let lon5 = try? Longitude(-4.5 * .pi, unit: .radian)
        XCTAssertNotNil(lon5)
        XCTAssertEqual(lon5!.value, lonM1)
    }
}
