//
//  File.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import XCTest
@testable import CoreMeasure

final class UnitTests: XCTestCase {
    
    func testUnitMultipleSymbol() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let unit = UnitMultiple(factor: 100.0, unit: .metre)
        XCTAssertEqual(unit.symbol, "100m")
        
        let unit2 = UnitMultiple(factor: 100.12310001, unit: .metre)
        XCTAssertEqual(unit2.symbol, "100.1231m")
    }
    
    func testConversionFactors() {
        let kilometre = PrefixedUnit(prefix: .kilo, unit: .metre)
        XCTAssertEqual(kilometre.conversionFactor, 1000.0)
        XCTAssertEqual(kilometre.baseUnit, .metre)
        
        let m_s = UnitDivision(numerator: .metre, denominator: .second)
        let km_s = UnitDivision(numerator: kilometre, denominator: .second)
        XCTAssertEqual(km_s.conversionFactor, 1000.0)
        XCTAssertEqual(km_s.baseUnit, m_s)
        
        let hour = UnitMultiple(factor: 3600.0, unit: .second)
        XCTAssertEqual(hour.conversionFactor, 3600.0)
        XCTAssertEqual(hour.baseUnit, .second)
        let km_h = UnitDivision(numerator: kilometre, denominator: hour)
        XCTAssertEqual(km_h.conversionFactor, 1.0/3.6)
        XCTAssertEqual(km_h.baseUnit, m_s)
        
        let m_s_s = UnitDivision(numerator: m_s, denominator: .second)
        let s2 = UnitExponentiation(base: .second, exponent: 2)
        let m_s2 = UnitDivision(numerator: .metre, denominator: s2)
        XCTAssertEqual(m_s_s.conversionFactor, m_s2.conversionFactor)
        XCTAssertEqual(m_s_s.baseUnit, m_s2)
        
        let ly2pc = Unit.lightYear.conversionFactor / Unit.parsec.conversionFactor
        XCTAssertEqual(ly2pc, 0.306601, accuracy: 0.000001)
    }
}
