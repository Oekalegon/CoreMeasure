//
//  Astronomy.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public extension OMUnit {
    
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
    
    static let magnitude = OMUnit(symbol: "mag")
}

public class Magnitude: Quantity {
    
    /// Creates a copy of the ``Measure`` in a specific `Magnitude`.
    /// - Parameters:
    ///   - symbol: An optional symbol used for the quantity.
    ///   - measure: The measure to be copied in the quanity.
    public override init(symbol: String? = nil, measure: Measure) throws {
        if measure.unit.dimensions != OMUnit.magnitude.dimensions {
            throw UnitValidationError.differentDimensionality
        }
        try super.init(symbol: symbol, measure: measure)
    }
    
    public init(symbol: String? = nil, _ magnitude: Double, error: Double? = nil) throws {
        try super.init(symbol: symbol, magnitude, error: error, unit: .magnitude)
    }
}
