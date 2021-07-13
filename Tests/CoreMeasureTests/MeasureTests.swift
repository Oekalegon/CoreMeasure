//
//  File.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import XCTest
@testable import CoreMeasure

final class MeasureTests: XCTestCase {
    
    func testUnitConversion() {
        let m_s = UnitDivision(numerator: .metre, denominator: .second)
        let kilometre = PrefixedUnit(prefix: .kilo, unit: .metre)
        let km_h = UnitDivision(numerator: kilometre, denominator: .hour)
        let m1 = Measure(10, unit: m_s)
        let m2 = try? m1.convert(to: km_h)
        XCTAssertNotNil(m2)
        XCTAssertEqual(m2!.scalarValue, 36, accuracy: 0.01)
        XCTAssertEqual(m2!.unit, km_h)
        XCTAssertEqual(m2!.description, "36.0 km/h")
    }
    
    func testSubunits() {
        let m_deg = Measure(0.5, unit: .degree)
        let m_arcmin = try? m_deg.convert(to: .arcminute)
        let m_arcsec = try? m_deg.convert(to: .arcsecond)
        XCTAssertNotNil(m_arcmin)
        XCTAssertNotNil(m_arcsec)
        XCTAssertEqual(m_arcmin!.scalarValue, 30.0, accuracy: 0.000001)
        XCTAssertEqual(m_arcsec!.scalarValue, 1800.0, accuracy: 0.000001)
    }
    
    func testAddition() {
        let m1 = Measure(2000, unit: .metre)
        let m2 = Measure(1, unit: .kilometre)
        let m3 = try? m1 + m2
        XCTAssertNotNil(m3)
        XCTAssertEqual(m3!.unit, .metre)
        XCTAssertEqual(m3!.scalarValue, 3000.0, accuracy: 0.000001)
        XCTAssertNotEqual(m3!.scalarValue, 3001.0, accuracy: 0.000001)
        XCTAssertNotEqual(m3!.scalarValue, 2999.0, accuracy: 0.000001)
        
        let m4 = try? m2 + m1
        XCTAssertNotNil(m4)
        XCTAssertEqual(m4!.unit, .kilometre)
        XCTAssertEqual(m4!.scalarValue, 3.0, accuracy: 0.000001)
        XCTAssertNotEqual(m4!.scalarValue, 3.0001, accuracy: 0.000001)
        XCTAssertNotEqual(m4!.scalarValue, 2.9999, accuracy: 0.000001)
    }
    
    func testSubtraction() {
        let m1 = Measure(2000, unit: .metre)
        let m2 = Measure(1, unit: .kilometre)
        let m3 = try? m1 - m2
        XCTAssertNotNil(m3)
        XCTAssertEqual(m3!.unit, .metre)
        XCTAssertEqual(m3!.scalarValue, 1000.0, accuracy: 0.000001)
        XCTAssertNotEqual(m3!.scalarValue, 1001.0, accuracy: 0.000001)
        XCTAssertNotEqual(m3!.scalarValue, 999.0, accuracy: 0.000001)
        
        let m4 = try? m2 - m1
        XCTAssertNotNil(m4)
        XCTAssertEqual(m4!.unit, .kilometre)
        XCTAssertEqual(m4!.scalarValue, -1.0, accuracy: 0.000001)
        XCTAssertNotEqual(m4!.scalarValue, -1.0001, accuracy: 0.000001)
        XCTAssertNotEqual(m4!.scalarValue, -0.9999, accuracy: 0.000001)
    }
    
    func testMultiplication() {
        let m1 = Measure(2000, unit: .metre)
        let m2 = Measure(1, unit: .kilometre)
        let m3 = m1 * m2
        let m4 = try? m3.convert(to: .squareMetre)
        XCTAssertEqual(m4!.unit, .squareMetre)
        XCTAssertEqual(m4!.scalarValue, 2000000.0, accuracy: 0.000001)
    }
    
    func testDivision() {
        let m1 = Measure(2000, unit: .metre)
        let m2 = Measure(2, unit: .second)
        let m3 = m1 / m2
        XCTAssertEqual(m3.unit, .metrePerSecond)
        XCTAssertEqual(m3.scalarValue, 1000.0, accuracy: 0.000001)
    }
    
    func testCompoundAngleUnits() {
        let m1 = Measure(167.43212, unit: .degree)
        let m2 = try! m1.convert(to: .degreeArcminuteArcsecond)
        print("\(m2)")
        XCTAssertEqual(m2.description, "167° 25' 56\"")
        let m3 = try! m1.convert(to: .angleHourMinuteSecond)
        print("\(m3)")
        XCTAssertEqual(m3.description, "11h 09m 44s")
        
        let m4 = Measure(179.9999, unit: .degree)
        let m5 = try! m4.convert(to: .degreeArcminuteArcsecond)
        print("\(m5)")
        XCTAssertEqual(m5.description, "180° 00' 00\"")
        let m6 = try! m4.convert(to: .angleHourMinuteSecond)
        print("\(m6)")
        XCTAssertEqual(m6.description, "12h 00m 00s")
        
        let m7 = Measure(-32.5, unit: .degree)
        let m8 = try! m7.convert(to: .signDegreeArcminuteArcsecond)
        print("\(m8)")
        XCTAssertEqual(m8.description, "-32° 30' 00\"")
    }
    
    func testCompoundAngleUnitsForScales() {
        let ratioScale = RatioScale(symbol: nil, with: .radian)
        let angleScale = IntervalScale(reltativeTo: ratioScale, offset: Measure(-10, unit: .signDegreeArcminuteArcsecond))
        let m1 = Measure(0, scale: ratioScale)
        let m2 = try! m1.convert(to: angleScale)
        print("\(m2)")
        XCTAssertEqual(m2.description, "-10° 00' 00\"")
    }
    
    func testMeasureComparisson() {
        let m1 = Measure(2000, unit: .metre)
        let m2 = Measure(1, unit: .kilometre)
        XCTAssertTrue(m1 > m2)
        XCTAssertFalse(m2 > m1)
        XCTAssertFalse(m1 < m2)
        XCTAssertTrue(m2 < m1)
        XCTAssertTrue(m2 <= m1)
        XCTAssertFalse(m1 <= m2)
        XCTAssertFalse(m2 >= m1)
        XCTAssertTrue(m1 >= m2)
        
        // Uncomparable and should always return false
        let m3 = Measure(1, unit: .kilogram)
        XCTAssertFalse(m1 > m3)
        XCTAssertFalse(m3 > m1)
        XCTAssertFalse(m1 < m3)
        XCTAssertFalse(m3 < m1)
        XCTAssertFalse(m3 <= m1)
        XCTAssertFalse(m1 <= m3)
        XCTAssertFalse(m3 >= m1)
        XCTAssertFalse(m1 >= m3)
    }
    
    func testScales() {
        do {
            let t1 = Measure(0, scale: .kelvinScale)
            let t2 = try t1.convert(to: .celciusScale)
            XCTAssertEqual(t2.scalarValue, -273.15, accuracy: 0.000001)
            let t3 = try t2.convert(to: .kelvinScale)
            XCTAssertEqual(t3.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t1, t3)
            let t1f = Measure(0, scale: .kelvinScale)
            let t2f = try t1.convert(to: .fahrenheitScale)
            XCTAssertEqual(t2f.scalarValue, -459.67, accuracy: 0.000001)
            let t3f = try t2f.convert(to: .kelvinScale)
            XCTAssertEqual(t3f.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t1f, t3f)
            
            let t4 = Measure(0, scale: .celciusScale)
            let t5 = try t4.convert(to: .kelvinScale)
            XCTAssertEqual(t5.scalarValue, 273.15, accuracy: 0.000001)
            let t6 = try t5.convert(to: .celciusScale)
            XCTAssertEqual(t6.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t4, t6)
            XCTAssertNotEqual(t1,t6)
            
            let t4f = Measure(0, scale: .fahrenheitScale)
            let t5f = try t4f.convert(to: .kelvinScale)
            XCTAssertEqual(t5f.scalarValue, 255.3722222222, accuracy: 0.000001)
            let t6f = try t5f.convert(to: .fahrenheitScale)
            XCTAssertEqual(t6f.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t4f, t6f)
            XCTAssertNotEqual(t1f,t6f)
            
            let t11 = Measure(0, scale: .celciusScale)
            let t12 = try t11.convert(to: .fahrenheitScale)
            XCTAssertEqual(t12.scalarValue, 32.0, accuracy: 0.000001)
            
            let t7 = Measure(29, scale: .celciusScale)
            let t8 = try t7.convert(to: .fahrenheitScale)
            XCTAssertEqual(t8.scalarValue, 84.2, accuracy: 0.000001)
            let t9 = try t8.convert(to: .celciusScale)
            XCTAssertEqual(t9.scalarValue, 29.0, accuracy: 0.000001)
            XCTAssertEqual(t7, t9)
            XCTAssertNotEqual(t1,t9)
            let t10 = try t8.convert(to: .kelvinScale)
            XCTAssertEqual(t10.scalarValue, 302.15, accuracy: 0.000001)
            XCTAssertEqual(t7, t10)
            
            let t13 = Measure(100, scale: .réaumurScale)
            let t14 = try t13.convert(to: .fahrenheitScale)
            XCTAssertEqual(t14.scalarValue, 257, accuracy: 0.000001)
            let t15 = try t13.convert(to: .réaumurScale)
            XCTAssertEqual(t15.scalarValue, 100.0, accuracy: 0.000001)
            XCTAssertEqual(t13, t15)
        } catch {
            XCTFail()
        }
    }
    
    func testScaleComparisson() {
        let t1k = Measure(200, scale: .kelvinScale)
        let t2k = Measure(400, scale: .kelvinScale)
        let t1c = Measure(-100, scale: .celciusScale)
        let t2c = Measure(300, scale: .celciusScale)
        let t1r = Measure(179, scale: .réaumurScale)
        let t2r = Measure(-139, scale: .réaumurScale)
        
        XCTAssertTrue(t1k < t2k)
        XCTAssertFalse(t1k > t2k)
        XCTAssertFalse(t1k > t2k)
        XCTAssertTrue(t1k < t2k)
        
        XCTAssertTrue(t1c < t1k)
        XCTAssertTrue(t2c > t2k)
        
        XCTAssertTrue(t1c > t2r)
        XCTAssertTrue(t2c > t1r)
    }
}
