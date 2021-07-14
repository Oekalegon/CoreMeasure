//
//  ArithmeticTests.swift
//  
//
//  Created by Don Willems on 14/07/2021.
//

import XCTest
@testable import CoreMeasure

final class ArithmeticTests: XCTestCase {
    
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
}
