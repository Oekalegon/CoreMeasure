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
        let m1 = try! Measure(10, unit: m_s)
        let m2 = try? m1.convert(to: km_h)
        XCTAssertNotNil(m2)
        XCTAssertEqual(m2!.scalarValue, 36, accuracy: 0.01)
        XCTAssertEqual(m2!.unit, km_h)
        XCTAssertEqual(m2!.description, "36.0 km/h")
    }
    
    func testSubunits() {
        let m_deg = try! Measure(0.5, unit: .degree)
        let m_arcmin = try? m_deg.convert(to: .arcminute)
        let m_arcsec = try? m_deg.convert(to: .arcsecond)
        XCTAssertNotNil(m_arcmin)
        XCTAssertNotNil(m_arcsec)
        XCTAssertEqual(m_arcmin!.scalarValue, 30.0, accuracy: 0.000001)
        XCTAssertEqual(m_arcsec!.scalarValue, 1800.0, accuracy: 0.000001)
    }
    
    func testAddition() {
        let m1 = try! Measure(2000, unit: .metre)
        let m2 = try! Measure(1, unit: .kilometre)
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
        let m1 = try! Measure(2000, unit: .metre)
        let m2 = try! Measure(1, unit: .kilometre)
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
        let m1 = try! Measure(2000, unit: .metre)
        let m2 = try! Measure(1, unit: .kilometre)
        let m3 = m1 * m2
        let m4 = try? m3.convert(to: .squareMetre)
        XCTAssertEqual(m4!.unit, .squareMetre)
        XCTAssertEqual(m4!.scalarValue, 2000000.0, accuracy: 0.000001)
    }
    
    func testDivision() {
        let m1 = try! Measure(2000, unit: .metre)
        let m2 = try! Measure(2, unit: .second)
        let m3 = m1 / m2
        XCTAssertEqual(m3.unit, .metrePerSecond)
        XCTAssertEqual(m3.scalarValue, 1000.0, accuracy: 0.000001)
    }
    
    func testCompoundAngleUnits() {
        let m1 = try! Measure(167.43212, unit: .degree)
        let m2 = try! m1.convert(to: .degreeArcminuteArcsecond)
        print("\(m2)")
        XCTAssertEqual(m2.description, "167° 25' 56\"")
        let m3 = try! m1.convert(to: .angleHourMinuteSecond)
        print("\(m3)")
        XCTAssertEqual(m3.description, "11h 09m 44s")
        
        let m4 = try! Measure(179.99999999, unit: .degree)
        let m5 = try! m4.convert(to: .degreeArcminuteArcsecond)
        print("\(m5)")
        XCTAssertEqual(m5.description, "180° 00' 00\"")
        let m6 = try! m4.convert(to: .angleHourMinuteSecond)
        print("\(m6)")
        XCTAssertEqual(m6.description, "12h 00m 00s")
        
        let m7 = try! Measure(-32.5, unit: .degree)
        let m8 = try! m7.convert(to: .signDegreeArcminuteArcsecond)
        print("\(m8)")
        XCTAssertEqual(m8.description, "-32° 30' 00\"")
    }
    
    func testCompoundAngleUnitsForScales() {
        let ratioScale = RatioScale(symbol: nil, with: .radian)
        let angleScale = IntervalScale(reltativeTo: ratioScale, offset: try! Measure(-10, unit: .signDegreeArcminuteArcsecond))
        let m1 = try! Measure(0, scale: ratioScale)
        let m2 = try! m1.convert(to: angleScale)
        print("\(m2)")
        XCTAssertEqual(m2.description, "-10° 00' 00\"")
    }
    
    func testMeasureComparisson() {
        let m1 = try! Measure(2000, unit: .metre)
        let m2 = try! Measure(1, unit: .kilometre)
        XCTAssertTrue(m1 > m2)
        XCTAssertFalse(m2 > m1)
        XCTAssertFalse(m1 < m2)
        XCTAssertTrue(m2 < m1)
        XCTAssertTrue(m2 <= m1)
        XCTAssertFalse(m1 <= m2)
        XCTAssertFalse(m2 >= m1)
        XCTAssertTrue(m1 >= m2)
        
        // Uncomparable and should always return false
        let m3 = try! Measure(1, unit: .kilogram)
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
            let t1 = try! Measure(0, scale: .kelvinScale)
            let t2 = try t1.convert(to: .celciusScale)
            XCTAssertEqual(t2.scalarValue, -273.15, accuracy: 0.000001)
            let t3 = try t2.convert(to: .kelvinScale)
            XCTAssertEqual(t3.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t1, t3)
            let t1f = try! Measure(0, scale: .kelvinScale)
            let t2f = try t1.convert(to: .fahrenheitScale)
            XCTAssertEqual(t2f.scalarValue, -459.67, accuracy: 0.000001)
            let t3f = try t2f.convert(to: .kelvinScale)
            XCTAssertEqual(t3f.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t1f, t3f)
            
            let t4 = try! Measure(0, scale: .celciusScale)
            let t5 = try t4.convert(to: .kelvinScale)
            XCTAssertEqual(t5.scalarValue, 273.15, accuracy: 0.000001)
            let t6 = try t5.convert(to: .celciusScale)
            XCTAssertEqual(t6.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t4, t6)
            XCTAssertNotEqual(t1,t6)
            
            let t4f = try! Measure(0, scale: .fahrenheitScale)
            let t5f = try t4f.convert(to: .kelvinScale)
            XCTAssertEqual(t5f.scalarValue, 255.3722222222, accuracy: 0.000001)
            let t6f = try t5f.convert(to: .fahrenheitScale)
            XCTAssertEqual(t6f.scalarValue, 0.0, accuracy: 0.000001)
            XCTAssertEqual(t4f, t6f)
            XCTAssertNotEqual(t1f,t6f)
            
            let t11 = try! Measure(0, scale: .celciusScale)
            let t12 = try t11.convert(to: .fahrenheitScale)
            XCTAssertEqual(t12.scalarValue, 32.0, accuracy: 0.000001)
            
            let t7 = try! Measure(29, scale: .celciusScale)
            let t8 = try t7.convert(to: .fahrenheitScale)
            XCTAssertEqual(t8.scalarValue, 84.2, accuracy: 0.000001)
            let t9 = try t8.convert(to: .celciusScale)
            XCTAssertEqual(t9.scalarValue, 29.0, accuracy: 0.000001)
            XCTAssertEqual(t7, t9)
            XCTAssertNotEqual(t1,t9)
            let t10 = try t8.convert(to: .kelvinScale)
            XCTAssertEqual(t10.scalarValue, 302.15, accuracy: 0.000001)
            XCTAssertEqual(t7, t10)
            
            let t13 = try! Measure(100, scale: .réaumurScale)
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
        let t1k = try! Measure(200, scale: .kelvinScale)
        let t2k = try! Measure(400, scale: .kelvinScale)
        let t1c = try! Measure(-100, scale: .celciusScale)
        let t2c = try! Measure(300, scale: .celciusScale)
        let t1r = try! Measure(179, scale: .réaumurScale)
        let t2r = try! Measure(-139, scale: .réaumurScale)
        
        XCTAssertTrue(t1k < t2k)
        XCTAssertFalse(t1k > t2k)
        XCTAssertFalse(t1k > t2k)
        XCTAssertTrue(t1k < t2k)
        
        XCTAssertTrue(t1c < t1k)
        XCTAssertTrue(t2c > t2k)
        
        XCTAssertTrue(t1c > t2r)
        XCTAssertTrue(t2c > t1r)
    }
    
    func testNominalAndOrdinalScales() {
        let nominalScale = NominalScale(symbol: "S", labels: ["house", "office"])
        let m1 = try? Measure("house", scale: nominalScale)
        let m2 = try? Measure("house", scale: nominalScale)
        let m3 = try? Measure("office", scale: nominalScale)
        XCTAssertNotNil(m1)
        XCTAssertNotNil(m2)
        XCTAssertNotNil(m3)
        XCTAssertEqual(m1, m2)
        XCTAssertNotEqual(m1, m3)
        let m4 = try? Measure("city", scale: nominalScale)
        XCTAssertNil(m4)
        
        XCTAssertFalse(m1!<m2!)
        XCTAssertFalse(m1!>m2!)
        XCTAssertFalse(m2!>m3!)
        
        let ordinalScale = OrdinalScale(symbol: "S2", labels: ["hamlet", "town", "city", "metropolis"])
        let m5 = try? Measure("metropolis", scale: ordinalScale)
        let m6 = try? Measure("metropolis", scale: ordinalScale)
        let m7 = try? Measure("hamlet", scale: ordinalScale)
        XCTAssertNotNil(m5)
        XCTAssertNotNil(m6)
        XCTAssertNotNil(m7)
        XCTAssertEqual(m5, m6)
        XCTAssertNotEqual(m5, m7)
        let m8 = try? Measure("cat", scale: ordinalScale)
        XCTAssertNil(m8)
        XCTAssertTrue(m5!>m7!)
        XCTAssertTrue(m5!==m6!)
        XCTAssertTrue(m5!<=m6!)
        XCTAssertTrue(m5!>=m6!)
        XCTAssertFalse(m5!<m7!)
        
        XCTAssertNotEqual(nominalScale, ordinalScale)
    }
    
    func testDisplay() {
        let m1 = try! Measure(123, error: 2, unit: .metre)
        XCTAssertEqual(m1.description, "123 ±2 m")
        let m2 = try! Measure(-123, error: 2, unit: .metre)
        XCTAssertEqual(m2.description, "-123 ±2 m")
        
        let m3 = try! Measure(123, error: 20, unit: .metre)
        XCTAssertEqual(m3.description, "1.2 ±0.2 ⨉ 10^2 m")
        let m4 = try! Measure(-123, error: 20, unit: .metre)
        XCTAssertEqual(m4.description, "-1.2 ±0.2 ⨉ 10^2 m")
        
        let m5 = try! Measure(123.45, error: 0.02, unit: .metre)
        XCTAssertEqual(m5.description, "123.45 ±0.02 m")
        let m6 = try! Measure(-123.45, error: 0.02, unit: .metre)
        XCTAssertEqual(m6.description, "-123.45 ±0.02 m")
        
        let m7 = try! Measure(0.012345, error: 0.002, unit: .metre)
        XCTAssertEqual(m7.description, "1.2 ±0.2 ⨉ 10^-2 m")
        let m8 = try! Measure(-0.012345, error: 0.002, unit: .metre)
        XCTAssertEqual(m8.description, "-1.2 ±0.2 ⨉ 10^-2 m")
        
        let m9 = try! Measure(0.12545, error: 0.02, unit: .metre)
        XCTAssertEqual(m9.description, "1.3 ±0.2 ⨉ 10^-1 m")
        let m10 = try! Measure(-0.12545, error: 0.02, unit: .metre)
        XCTAssertEqual(m10.description, "-1.3 ±0.2 ⨉ 10^-1 m")
        
        let m11 = try! Measure(0.012545, unit: .metre)
        XCTAssertEqual(m11.description, "0.012545 m")
        let m12 = try! Measure(12.545, unit: .metre)
        XCTAssertEqual(m12.description, "12.545 m")
        
        let m13 = try! Measure(0.0001234567893345, unit: .metre)
        XCTAssertEqual(m13.description, "1.234567893 ⨉ 10^-4 m")
        let m14 = try! Measure(12345.67893345, unit: .metre)
        XCTAssertEqual(m14.description, "1.234567893 ⨉ 10^4 m")
        
        let m15 = try! Measure(0.0001234, unit: .metre)
        XCTAssertEqual(m15.description, "1.234 ⨉ 10^-4 m")
        let m16 = try! Measure(12340, unit: .metre)
        XCTAssertEqual(m16.description, "1.234 ⨉ 10^4 m")
        
        let d1 = try! Measure(23.5384, error: 0.002, unit: .degree)
        XCTAssertEqual(d1.description, "23°538 ±0°002")
        
        let d2 = try! Measure(0.0032, error: 0.0002, unit: .degree)
        XCTAssertEqual(d2.description, "3.2 ±0.2 ⨉ 10^-3°")
        
        let m17 = try! Measure(122.25, unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m17.description, "122° 15' 00\"")
        let m18 = try! Measure(-34.50, unit: .signDegreeArcminuteArcsecond)
        XCTAssertEqual(m18.description, "-34° 30' 00\"")
        var m19 = try! Measure(122.25, unit: .degree)
        m19 = try! m19.convert(to: .angleHourMinuteSecond)
        XCTAssertEqual(m19.description, "8h 09m 00s")
        
        // "122° 15' 52"126
        let m20 = try! Measure(122.264479444, error: 0.033,unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m20.description, "122° 16' ±2'")
        // "-34° 30' 52"126
        let m21 = try! Measure(-34.514479444, error: 0.033, unit: .signDegreeArcminuteArcsecond)
        XCTAssertEqual(m21.description, "-34° 31' ±2'")
        // 8h 09m 30s123
        var m22 = try! Measure(122.3755125, error: 0.3, unit: .degree)
        m22 = try! m22.convert(to: .angleHourMinuteSecond)
        XCTAssertEqual(m22.description, "8h 10m ±1m")
        
        // "122° 15' 52"126
        let m23 = try! Measure(122.264479444, error: 0.0000028,unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m23.description, "122° 15' 52\"13 ±10 mas")
        // "-34° 30' 52"126
        let m24 = try! Measure(-34.514479444, error: 0.0000028, unit: .signDegreeArcminuteArcsecond)
        XCTAssertEqual(m24.description, "-34° 30' 52\"13 ±10 mas")
        // 8h 09m 30s123
        var m25 = try! Measure(122.3755125, error: 0.0000041666667, unit: .degree)
        m25 = try! m25.convert(to: .angleHourMinuteSecond)
        XCTAssertEqual(m25.description, "8h 09m 30s123 ±15 mas")
        
        let m27 = try! Measure(122.2644444444+0.001/3600.0, error: 0.0011/3600.0,unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m27.description, "122° 15' 52\"001 ±1 mas")
        // "122° 15' 52"126000000
        let m28 = try! Measure(122.2644444444+0.13/3600.0, error: 0.0000000000277777777778,unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m28.description, "122° 15' 52\"1300000 ±0.1 μas")
        let m29 = try! Measure(122.2644444444+0.13/3600.0, error: 0.000000000277777777778,unit: .degreeArcminuteArcsecond)
        XCTAssertEqual(m29.description, "122° 15' 52\"130000 ±1 μas")

        let m26 = try! Measure(-34.516666, error: 0.01666666667, unit: .signDegreeArcminuteArcsecond)
        XCTAssertEqual(m26.description, "-34° 31' ±1'")
    }
}
