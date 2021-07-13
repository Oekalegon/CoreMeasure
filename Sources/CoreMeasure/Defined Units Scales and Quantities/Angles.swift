//
//  Angles.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public extension Unit {
    
    /// The degree is a unit for specifying angles where 1 degree (´1°´) equals 1/360th of a rotation.
    static let degree = UnitMultiple(symbol: "°", factor: .pi/180.0, unit: .radian)
    
    /// The arcminute is a unit for specifying angles and equals 1/60th of a ``degree``.
    ///
    /// It is most often used together with degrees, and arcseconds to represent angles in a compound
    /// unit (``degreeArcminuteArcsecond``, e.g. 12°45´22").
    static let arcminute = UnitMultiple(symbol: "'", factor: 1.0/60.0, unit: degree)
    
    /// The arcsecond is a unit for specifying angles and equals 1/3600th of a ``degree``.
    /// It is often used together with degrees, and arcseconds to represent angles in a compound unit
    /// (``degreeArcminuteArcsecond``, e.g. 12°45´22"), but also to represents small angles (i.e. as errors in an angle).
    static let arcsecond = UnitMultiple(symbol: "\"", factor: 1.0/3600.0, unit: degree)
    
    /// The milliarcsecond is a unit for specifying angles and equals 1/1000th of an ``arcsecond``.
    ///
    /// It is used to specify very small angles (e.g. in astronomy).
    static let milliarcsecond = PrefixedUnit(symbol: "mas", prefix: .milli, unit: .arcsecond)
    
    /// The microarcsecond is a unit for specifying angles and equals 1/1000000th of an ``arcsecond``.
    ///
    /// It is used to specify extremely small angles (e.g. in astronomy).
    static let microarcsecond = PrefixedUnit(symbol: "μas",prefix: .micro, unit: .arcsecond)
    
    /// The hour is a unit for specifying angles and equals 15° or 1/24th of a complete rotation. The unit
    /// has the name ``angleHour`` to distinguish it from the more common time unit ``hour``.
    ///
    /// It is almost exclusively used in astronomy, especially when defining a longitude (right ascension) in
    /// the equatorial coordinate system. Together with ``angleMinute`` and ``angleSecond`` it is
    /// used in a compound unit when specifying a right ascension (``angleHourMinuteSecond``, e.g. 14h32m12s2)
    static let angleHour = UnitMultiple(symbol: "h", factor: 15.0, unit: degree)
    
    /// The minute is a unit for specifying angles and equals 0.25° or 1/60th of an hour. The unit
    /// has the name ``angleMinute`` to distinguish it from the more common time unit ``minute``.
    ///
    /// It is almost exclusively used in astronomy, especially when defining a longitude (right ascension) in
    /// the equatorial coordinate system. Together with ``angleHour`` and ``angleSecond`` it is
    /// used in a compound unit when specifying a right ascension (``angleHourMinuteSecond``, e.g. 14h32m12s2).
    static let angleMinute = UnitMultiple(symbol: "m", factor: 1.0/60.0, unit: angleHour)
    
    /// The secomd is a unit for specifying angles and 1/60th of a minute. The unit
    /// has the name ``angleSecond`` to distinguish it from the more common time unit ``second``.
    ///
    /// It is almost exclusively used in astronomy, especially when defining a longitude (right ascension) in
    /// the equatorial coordinate system.  Together with ``angleHour`` and ``angleMinute`` it is
    /// used in a compound unit when specifying a right ascension  (``angleHourMinuteSecond``, e.g. 14h32m12s2).
    static let angleSecond = UnitMultiple(symbol: "s", factor: 1.0/3600.0, unit: angleHour)
    
    /// This compound unit is used to specify angles in a combination of ``degree``, ``arcminute``,
    /// and ``arcsecond``, e.g. 12°45´22".
    static let degreeArcminuteArcsecond = try! CompoundUnit(consistingOf: [degree, arcminute, arcsecond], displaySign: false)
    
    /// This compound unit is used to specify angles in a combination of ``degree``, ``arcminute``,
    /// and ``arcsecond``, e.g. +12°45´22".
    ///
    /// A sign is always prepended to the string description of the angle even when the angle is positive.
    /// If you do not want the sign prepended (i.e. only with negative angles), use
    /// ``degreeArcminuteArcsecond``.
    /// It is used mostly to define geographical or astronomical longitudes and latitudes.
    static let signDegreeArcminuteArcsecond = try! CompoundUnit(consistingOf: [degree, arcminute, arcsecond], displaySign: true)
    
    /// This compound unit is used to specify angles in a combination of hours (``angleHour``) ,
    /// minutes (``angleMinute``), and seconds (``angleSecond``), e.g. 14h32m12s2.
    ///
    /// It is almost exclusively used in astronomy, especially when defining a longitude (right ascension) in
    /// the equatorial coordinate system.
    static let angleHourMinuteSecond = try! CompoundUnit(consistingOf: [angleHour, angleMinute, angleSecond])
}

/// An angle is a designation for the measure of a rotation.
///
/// Angles are dimensionless quantities and are often specified in radians or degrees.
public class Angle: Quantity {
    
    /// Creates a new angle with the specified value.
    ///
    /// This initialiser checks whether the dimensions of the (unit of the) value corresponds to the
    /// dimensions expected for an angle. An angle is, as a matter of fact, a dimensionless quantity.
    /// Units like `.radians` or `.degrees` are used for angles.
    /// - Parameters:
    ///   - symbol: The symbol used for the angle quantity.
    ///   - value: The value for the angle.
    /// - Throws: A ``UnitValidationError`` when the dimensions of the value do not
    /// correspond to the dimensions of the quantity.
    public override init(symbol: String? = nil, _ value: Measure) throws {
        if value.unit.dimensions != Unit.radian.dimensions {
            throw UnitValidationError.differentDimensionality
        }
        try super.init(symbol: symbol, value)
    }
}

public class Latitude: Angle, Ranged {
    
    public let range : (min: Measure, max: Measure)
    
    public override init(symbol: String? = nil, _ value: Measure) throws {
        if value.unit.dimensions != Unit.radian.dimensions {
            throw UnitValidationError.differentDimensionality
        }
        let range = (min: Measure(-90, unit:.degree), max: Measure(90, unit:.degree))
        if value < range.min || value > range.max {
            throw QuantityValidationError.outOfRange
        }
        let converted = try value.convert(to: range.max.unit)
        self.range = range
        try super.init(symbol: symbol, converted)
    }
}

public class NormalisedAngle: Angle, Ranged {
    
    public let range : (min: Measure, max: Measure)
    
    public override init(symbol: String? = nil, _ value: Measure) throws {
        if value.unit.dimensions != Unit.radian.dimensions {
            throw UnitValidationError.differentDimensionality
        }
        let range = (min: Measure(0, unit:.degree), max: Measure(360, unit:.degree))
        var converted = try value.convert(to: range.max.unit)
        if value < range.min || value > range.max {
            var newValue = converted.scalarValue.truncatingRemainder(dividingBy: 360.0)
            if newValue < 0 {
                newValue = newValue + 360.0
            }
            converted = Measure(newValue, unit: range.max.unit)
        }
        self.range = range
        try super.init(symbol: symbol, converted)
    }
}

public class Longitude: NormalisedAngle {
}
