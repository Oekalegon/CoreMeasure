//
//  Astronomy.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public extension Unit {
    
    static let parsec = UnitMultiple(symbol: "pc", factor: 30856775714409184.00, unit: metre)
    static let kiloparsec = PrefixedUnit(prefix: .kilo, unit: .parsec)
    static let megaparsec = PrefixedUnit(prefix: .mega, unit: .parsec)
    static let gigaparsec = PrefixedUnit(prefix: .giga, unit: .parsec)
    
    static let lightYear = UnitMultiple(symbol: "ly", factor: 9460730472580800.0, unit: metre)
    static let lightSecond = UnitMultiple(symbol: "lsec", factor: 299792458.0, unit: metre)
    static let lightMinute = UnitMultiple(symbol: "lmin", factor: 60, unit: lightSecond)
    static let lightHour = UnitMultiple(symbol: "lhr", factor: 3600, unit: lightSecond)
    static let lightDay = UnitMultiple(symbol: "lday", factor: 86400, unit: lightSecond)
    static let lightWeek = UnitMultiple(symbol: "lday", factor: 7, unit: lightDay)
    
    static let astronomicalUnit = UnitMultiple(symbol: "AU", factor: 149597870700.0, unit: metre)
}
