//
//  ArithmeticTests.swift
//  
//
//  Created by Don Willems on 14/07/2021.
//

import XCTest
@testable import CoreMeasure

final class ArithmeticTests: XCTestCase {
    
    // MARK: Trigonometric function tests
    
    func testTrigonometry1() {
        let angle1 = try! Angle(30, unit: .degree)
        let sinAngle1 = sin(angle1)
        XCTAssertEqual(sinAngle1.scalarValue, 0.5, accuracy: 0.0000001)
        XCTAssertEqual(sinAngle1.unit, .one)
        let asinAngle1 = asin(sinAngle1)
        XCTAssertEqual(asinAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(asinAngle1.unit, .radian)
        
        let cosAngle1 = cos(angle1)
        XCTAssertEqual(cosAngle1.scalarValue, sqrt(3)/2, accuracy: 0.0000001)
        XCTAssertEqual(cosAngle1.unit, .one)
        let acosAngle1 = acos(cosAngle1)
        XCTAssertEqual(acosAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(acosAngle1.unit, .radian)
        
        let tanAngle1 = tan(angle1)
        XCTAssertEqual(tanAngle1.scalarValue, 1/sqrt(3), accuracy: 0.0000001)
        XCTAssertEqual(tanAngle1.unit, .one)
        let atanAngle1 = atan(tanAngle1)
        XCTAssertEqual(atanAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle1.unit, .radian)
        
        let m1 = try! Measure(1.0, unit: .metre)
        let m2 = try! Measure(sqrt(3), unit: .metre)
        let atanAngle2 = try? atan(m1, m2)
        XCTAssertNotNil(atanAngle2)
        XCTAssertEqual(atanAngle2!.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle2!.unit, .radian)
    }
    
    func testTrigonometry2() {
        let angle1 = try! Angle(150, unit: .degree)
        let sinAngle1 = sin(angle1)
        XCTAssertEqual(sinAngle1.scalarValue, 0.5, accuracy: 0.0000001)
        XCTAssertEqual(sinAngle1.unit, .one)
        let asinAngle1 = asin(sinAngle1)
        XCTAssertEqual(asinAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(asinAngle1.unit, .radian)
        
        let cosAngle1 = cos(angle1)
        XCTAssertEqual(cosAngle1.scalarValue, -sqrt(3)/2, accuracy: 0.0000001)
        XCTAssertEqual(cosAngle1.unit, .one)
        let acosAngle1 = acos(cosAngle1)
        XCTAssertEqual(acosAngle1.scalarValue, 5*Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(acosAngle1.unit, .radian)
        
        let tanAngle1 = tan(angle1)
        XCTAssertEqual(tanAngle1.scalarValue, -1/sqrt(3), accuracy: 0.0000001)
        XCTAssertEqual(tanAngle1.unit, .one)
        let atanAngle1 = atan(tanAngle1)
        XCTAssertEqual(atanAngle1.scalarValue, -Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle1.unit, .radian)
        
        let m1 = try! Measure(1.0, unit: .metre)
        let m2 = try! Measure(-sqrt(3), unit: .metre)
        let atanAngle2 = try? atan(m1, m2)
        XCTAssertNotNil(atanAngle2)
        XCTAssertEqual(atanAngle2!.scalarValue, 5*Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle2!.unit, .radian)
    }
    
    func testTrigonometry3() {
        let angle1 = try! Angle(210, unit: .degree)
        let sinAngle1 = sin(angle1)
        XCTAssertEqual(sinAngle1.scalarValue, -0.5, accuracy: 0.0000001)
        XCTAssertEqual(sinAngle1.unit, .one)
        let asinAngle1 = asin(sinAngle1)
        XCTAssertEqual(asinAngle1.scalarValue, -Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(asinAngle1.unit, .radian)
        
        let cosAngle1 = cos(angle1)
        XCTAssertEqual(cosAngle1.scalarValue, -sqrt(3)/2, accuracy: 0.0000001)
        XCTAssertEqual(cosAngle1.unit, .one)
        let acosAngle1 = acos(cosAngle1)
        XCTAssertEqual(acosAngle1.scalarValue, 5*Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(acosAngle1.unit, .radian)
        
        let tanAngle1 = tan(angle1)
        XCTAssertEqual(tanAngle1.scalarValue, 1/sqrt(3), accuracy: 0.0000001)
        XCTAssertEqual(tanAngle1.unit, .one)
        let atanAngle1 = atan(tanAngle1)
        XCTAssertEqual(atanAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle1.unit, .radian)
        
        let m1 = try! Measure(-1.0, unit: .metre)
        let m2 = try! Measure(-sqrt(3), unit: .metre)
        let atanAngle2 = try? atan(m1, m2)
        XCTAssertNotNil(atanAngle2)
        XCTAssertEqual(atanAngle2!.scalarValue, -5*Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle2!.unit, .radian)
    }
    
    func testTrigonometry4() {
        let angle1 = try! Angle(330, unit: .degree)
        let sinAngle1 = sin(angle1)
        XCTAssertEqual(sinAngle1.scalarValue, -0.5, accuracy: 0.0000001)
        XCTAssertEqual(sinAngle1.unit, .one)
        let asinAngle1 = asin(sinAngle1)
        XCTAssertEqual(asinAngle1.scalarValue, -Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(asinAngle1.unit, .radian)
        
        let cosAngle1 = cos(angle1)
        XCTAssertEqual(cosAngle1.scalarValue, sqrt(3)/2, accuracy: 0.0000001)
        XCTAssertEqual(cosAngle1.unit, .one)
        let acosAngle1 = acos(cosAngle1)
        XCTAssertEqual(acosAngle1.scalarValue, Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(acosAngle1.unit, .radian)
        
        let tanAngle1 = tan(angle1)
        XCTAssertEqual(tanAngle1.scalarValue, -1/sqrt(3), accuracy: 0.0000001)
        XCTAssertEqual(tanAngle1.unit, .one)
        let atanAngle1 = atan(tanAngle1)
        XCTAssertEqual(atanAngle1.scalarValue, -Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle1.unit, .radian)
        
        let m1 = try! Measure(-1.0, unit: .metre)
        let m2 = try! Measure(sqrt(3), unit: .metre)
        let atanAngle2 = try? atan(m1, m2)
        XCTAssertNotNil(atanAngle2)
        XCTAssertEqual(atanAngle2!.scalarValue, -Double.pi/6, accuracy: 0.0000001)
        XCTAssertEqual(atanAngle2!.unit, .radian)
    }
    
    func testTrigonometrySpecialCases() {
        let asinAngle1 = asin(try! Measure(1.1, unit: .one))
        XCTAssertTrue(asinAngle1.scalarValue.isNaN)
        let asinAngle2 = asin(try! Measure(-1.1, unit: .one))
        XCTAssertTrue(asinAngle2.scalarValue.isNaN)
        let acosAngle1 = acos(try! Measure(1.1, unit: .one))
        XCTAssertTrue(acosAngle1.scalarValue.isNaN)
        let acosAngle2 = acos(try! Measure(-1.1, unit: .one))
        XCTAssertTrue(acosAngle2.scalarValue.isNaN)
        
        let atan1 = atan(try! Measure(Double.infinity, unit: .one))
        XCTAssertEqual(atan1.scalarValue, Double.pi/2, accuracy: 0.0000001)
        let tan1 = tan(atan1)
        XCTAssertEqual(tan1.scalarValue, Double.infinity)
        XCTAssertEqual(tan1.unit, .one)
        
        let atan2 = atan(try! Measure(-Double.infinity, unit: .one))
        XCTAssertEqual(atan2.scalarValue, -Double.pi/2, accuracy: 0.0000001)
        let tan2 = tan(atan2)
        XCTAssertEqual(tan2.scalarValue, -Double.infinity)
        XCTAssertEqual(tan2.unit, .one)
        
        let atan3 = try? atan(Measure(1.0, unit: .metre), Measure(0, unit: .metre))
        XCTAssertNotNil(atan3)
        XCTAssertEqual(atan3!.scalarValue, Double.pi/2, accuracy: 0.0000001)
        XCTAssertEqual(atan3!.unit, .radian)
        
        let atan4 = try? atan(Measure(-1.0, unit: .metre), Measure(0, unit: .metre))
        XCTAssertNotNil(atan4)
        XCTAssertEqual(atan4!.scalarValue, -Double.pi/2, accuracy: 0.0000001)
        XCTAssertEqual(atan4!.unit, .radian)
    }
    
    // MARK: SQRT tests
    
    func testSquarerootSpecialCases() {
        let m1 = try! Measure(-1.0, unit: .one)
        let sqrt1 = sqrt(m1)
        XCTAssertNotNil(sqrt1)
        XCTAssertTrue(sqrt1.scalarValue.isNaN)
        
        let m2 = try! Measure(0.0, unit: .one)
        let sqrt2 = sqrt(m2)
        XCTAssertNotNil(sqrt2)
        XCTAssertEqual(sqrt2.scalarValue, 0.0)
    }
    
    
    // MARK: Logarithm tests
    
    func testLogarithmsSpecialCases() {
        let m1 = try! Measure(-1.0, unit: .one)
        let log1 = log(m1)
        XCTAssertNotNil(log1)
        XCTAssertTrue(log1.scalarValue.isNaN)
        
        let m2 = try! Measure(0.0, unit: .one)
        let log2 = log(m2)
        XCTAssertNotNil(log2)
        XCTAssertEqual(log2.scalarValue, -Double.infinity)
        
        let log3 = log10(m1)
        XCTAssertNotNil(log3)
        XCTAssertTrue(log3.scalarValue.isNaN)
        
        let log4 = log10(m2)
        XCTAssertNotNil(log4)
        XCTAssertEqual(log4.scalarValue, -Double.infinity)
    }
    
    
    // MARK: Scale arithmetic
    
    func testScaleArithmetic() {
        let m1 = try! Measure(10.3, scale: .celciusScale)
        let m2 = try! Measure(5.7, unit:.kelvin)
        let m3 = try! Measure(5.6, scale: .kelvinScale)
        let m4 = try? m1 + m2
        XCTAssertNotNil(m4)
        XCTAssertEqual(m4!.scalarValue, 16.0, accuracy: 0.000001)
        XCTAssertEqual(m4!.unit , .degreeCelsius)
        
        let m5 = try? m1 + m3
        XCTAssertNil(m5)
        let m6 = try? m2 + m1
        XCTAssertNil(m6)
        
        let m7 = try? m1 - m2
        XCTAssertNotNil(m7)
        XCTAssertEqual(m7!.scalarValue, 4.6, accuracy: 0.000001)
        XCTAssertEqual(m7!.unit , .degreeCelsius)
        
        let m8 = try? m1 - m3
        XCTAssertNotNil(m8)
        XCTAssertNil(m8!.scale)
        XCTAssertEqual(m8!.scalarValue, 277.85, accuracy: 0.000001)
        XCTAssertEqual(m8!.unit , .kelvin)
        
        let m9 = try? m2 - m1
        XCTAssertNil(m9)
        
        let m10 = try? m3 - m2
        XCTAssertNil(m10)
    }
}
