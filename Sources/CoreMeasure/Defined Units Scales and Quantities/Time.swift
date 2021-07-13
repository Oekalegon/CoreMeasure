//
//  Time.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public extension Unit {
    
    static let hour = UnitMultiple(symbol: "h", factor: 3600.0, unit: .second)
    static let minute = UnitMultiple(symbol: "m", factor: 60.0, unit: .second)
    static let day = UnitMultiple(symbol: "days", factor: 86400.0, unit: .second)
    static let week = UnitMultiple(symbol: "weeks", factor: 604800.0, unit: .second)
    
    static let siderealYear = UnitMultiple(symbol: "sidereal years", factor: 365.256363004, unit: .day)
}

