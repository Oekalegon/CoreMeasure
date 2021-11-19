//
//  Measure+Arithmetic.swift
//  
//
//  Created by Don Willems on 14/07/2021.
//

import Foundation

extension Measure {
    
    /// Returns a measure with the inverted scalar value.
    /// - Parameter measure: The measure to be inverted.
    /// - Returns: The inverted value.
    /// - Throws:ScaleValidationError when the measure contains a value in a nominal or ordinal scale,
    /// which do not have associated values that have a known degree of variation, or when the measure
    /// contains a value in a ratio scale, for which a absolute zero is defined and, therefore, cannot have
    /// a negative value.
    public static prefix func - (measure: Measure) throws -> Measure {
        if measure.usesScale {
            if measure.usesIntervalOrRatioScale {
                if (measure.scale as? IntervalScale) != nil {
                    return try Measure(-measure.scalarValue, error: measure.error, scale: measure.scale as! IntervalScale)
                } else {
                    throw ScaleValidationError.negativeValuesNotAllowedInRatioScale
                }
            } else {
                throw ScaleValidationError.cannotUseArithmeticOnNominalOrOrdinalScale
            }
        }
        return try Measure(-measure.scalarValue, error: measure.error, unit: measure.unit)
    }
}


// MARK: Basic Arithmetic with Measures

/// Creates a new `Measure` instance with a value equal to the addition of the left and right hand
/// expression. The new measure is expressed in the same units as the left hand expression.
///
/// In the case of measures that are epressed on a measurement scale:
/// * If both measures are expressed as scales, addition is not allowed and a `ScaleValidationError.cannotUseScaleInArithmetic` is thrown.
/// * A point on a scale can also not be added to a non-scale measure and a `ScaleValidationError.cannotUseScaleInArithmetic` is thrown.
/// * Addition is, however, valid when a non-scale measure is added to a point on a scale. For instance one can add `5 K`to `10°C` and will result in a value of `15°C`, as  `1 K` is equal to `1°C` as a relative value.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the addition of the two measures. This result is another measure expressing
///  either a value with a unit, or a point on a measurement scale.
public func +(lhs: Measure, rhs: Measure) throws -> Measure {
    if rhs.usesScale {
        throw ScaleValidationError.cannotUseScaleInArithmetic
    }
    if lhs.usesScale && !lhs.usesIntervalOrRatioScale {
        throw ScaleValidationError.cannotUseArithmeticOnNominalOrOrdinalScale
    }
    let converted = try rhs.convert(to: lhs.unit)
    if lhs.usesIntervalOrRatioScale {
        return try Measure(lhs.scalarValue + converted.scalarValue, scale: (lhs.scale as! IntervalScale))
    }
    return try Measure(lhs.scalarValue + converted.scalarValue, unit: lhs.unit)
}

/// Creates a new `Measure` instance with a value equal to the subtraction of the right from the left hand
/// expression. The new measure is expressed in the same units as the left hand expression.
///
/// In the case of measures that are epressed on a measurement scale:
/// * If both measures are expressed as scales, subtraction is not allowed and a
/// `ScaleValidationError.cannotUseScaleInArithmetic` is thrown.
/// * A point on a scale can also not be subtracted to a non-scale measure and a
/// `ScaleValidationError.cannotUseScaleInArithmetic` is thrown.
/// * Subtraction is, however, valid when a non-scale measure is subtracted from a point on a scale.
/// For instance one can subtract `5 K`from `10°C` and will result in a value of `5°C`, as  `1 K` is equal to `1°C` as a relative value.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the addition of the two measures. This result is another measure expressing
///  either a value with a unit, or a point on a measurement scale.
public func -(lhs: Measure, rhs: Measure) throws -> Measure {
    if lhs.usesScale && !lhs.usesIntervalOrRatioScale {
        throw ScaleValidationError.cannotUseArithmeticOnNominalOrOrdinalScale
    }
    if rhs.usesScale && !rhs.usesIntervalOrRatioScale {
        throw ScaleValidationError.cannotUseArithmeticOnNominalOrOrdinalScale
    }
    if rhs.usesScale && !lhs.usesScale {
        throw ScaleValidationError.cannotUseScaleInArithmetic
    }
    if rhs.usesScale && lhs.usesScale {
        let converted = try rhs.convert(to: lhs.scale!)
        return try Measure(lhs.scalarValue - converted.scalarValue, unit: (lhs.scale as! IntervalScale).unit)
    }
    let converted = try rhs.convert(to: lhs.unit)
    if lhs.usesIntervalOrRatioScale {
        if (lhs.scale as? RatioScale) != nil {
            return try Measure(lhs.scalarValue - converted.scalarValue, scale: (lhs.scale as! RatioScale))
        }
        return try Measure(lhs.scalarValue - converted.scalarValue, scale: (lhs.scale as! IntervalScale))
    }
    return try Measure(lhs.scalarValue - converted.scalarValue, unit: lhs.unit)
}

/// Multiplies the left hand measure with the right hand measure and creates a new `Measure` with the
/// result of the multiplication. The unit of the result is a `UnitMultiplication` of the units of the
/// left and right hand expressions.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the multiplication
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the multiplicatipm of the two measures.
public func *(lhs: Measure, rhs: Measure) -> Measure {
    let unit = UnitMultiplication(multiplier: lhs.unit, multiplicand: rhs.unit)
    return try! Measure(lhs.scalarValue * rhs.scalarValue, unit: unit)
}


/// Multiplies the left hand value with the right hand measure and creates a new `Measure` with the
/// result of the multiplication. The unit of the result is the same as the unit in the right hand side measure.
///
/// The unit of the `Double` value on the left hand side is  taken to be `.one`, i.e. to be dimensionless.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the multiplication
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side value for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the multiplicatipm of the value with the measure.
public func *(lhs: Double, rhs: Measure) -> Measure {
    return try! Measure(lhs * rhs.scalarValue, unit: rhs.unit)
}


/// Multiplies the left hand measure with the right hand value and creates a new `Measure` with the
/// result of the multiplication.
///
/// The unit of the result is the same as the unit in the left hand side measure, because
/// the unit of the `Double` value on the rigjt hand side is  taken to be `.one`, i.e. to be dimensionless.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the multiplication
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side value for the operator.
///  - Returns: The result of the multiplicatipm of the value with the measure.
public func *(lhs: Measure, rhs: Double) -> Measure {
    return try! Measure(rhs * lhs.scalarValue, unit: lhs.unit)
}

/// Divides the left hand measure by the right hand measure and creates a new `Measure` with the
/// result of the division.
///
/// The unit of the result is a `UnitDivision` of the units of the left and right hand expressions.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the division
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the division of the two measures.
public func /(lhs: Measure, rhs: Measure) -> Measure {
    let unit = UnitDivision(numerator: lhs.unit, denominator: rhs.unit)
    return try! Measure(lhs.scalarValue / rhs.scalarValue, unit: unit)
}

/// Divides the left hand value by the right hand measure and creates a new `Measure` with the
/// result of the division.
///
/// The unit of the result is the reciprocal of the unit of the right hand side unit, because the unit of the
/// `Double` value on the left hand side is  taken to be `.one`, i.e. to be dimensionless.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the division
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side value for the operator.
///     - rhs: The right hand side measure for the operator.
///  - Returns: The result of the division of the value by the measure.
public func /(lhs: Double, rhs: Measure) -> Measure {
    let unit = UnitDivision(numerator: .one, denominator: rhs.unit)
    return try! Measure(lhs / rhs.scalarValue, unit: unit)
}

/// Divides the left hand measure by the right hand value and creates a new `Measure` with the
/// result of the division.
///
/// The unit of the result is the same as the unit of the left hand side, because the unit of the
/// `Double` value on the right hand side is  taken to be `.one`, i.e. to be dimensionless.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the division
/// but the offset of the scale is disregarded.
///
///  - Parameters:
///     - lhs: The left hand side measure for the operator.
///     - rhs: The right hand side value for the operator.
///  - Returns: The result of the division of the value by the measure.
public func /(lhs: Measure, rhs: Double) -> Measure {
    return try! Measure(lhs.scalarValue / rhs, unit: lhs.unit)
}


// MARK: Power and square root

/// Raises the measure to the power of the value of the `exponent`.
///
/// The unit of the result is the unit of the `base` raised to the same power (`exponent`), i.e.
/// a `UnitExponentiation`.
///
/// Points on a scale are used as non-scale measures where the value and unit are used in the power
/// expression, but the offset of the scale is disregarded.
///
///  - Parameters:
///     - base: The measure to be raised to the specified power.
///     - exponent: The exponent of tje power expression.
///  - Returns: The result of the measure raised to the power of the `exponent`.
public func pow(_ base: Measure, _ exponent: Double) -> Measure {
    let unit = UnitExponentiation(base: base.unit, exponent: exponent)
    let value = pow(base.scalarValue, Double(exponent))
    return try! Measure(value, unit: unit)
}

/// Raises the value to the power of the scalar value of the `exponent`.
///
/// The unit of the result is a dimesionless ``Measure`` with unit `.one`,
/// because the double value does not have a unit.
///  - Parameters:
///     - base: The value to be raised to the specified power.
///     - exponent: The exponent of tje power expression.
///  - Returns: The result of the value raised to the power of the `exponent`.
public func pow(_ base: Double, _ exponent: Measure) -> Measure {
    let value = pow(base, Double(exponent.scalarValue))
    return try! Measure(value, unit: .one)
}

/// Returns the square root of the ``Measure``.
///
/// The unit of the returned measure is also the square root of the unit of the specified measure.
/// - Parameter value: The measure whose square root is requested.
/// - Returns: The square root of the measure.
public func sqrt(_ value: Measure) -> Measure {
    let unit = UnitExponentiation(base: value.unit, exponent: 0.5)
    let newValue = sqrt(value.scalarValue)
    return try! Measure(newValue, unit: unit)
}

    
// MARK: Logarithms


/// Returns the natural logarithm for the specified value.
///
/// The unit of the result is the dimensionless unit `.one`.
/// The rationele behind this is that if the value of the argument does have a unit, one actually tries to
/// take the logarithm of the value divided by the unit of the value, e.g. log(10 km) = log(10 km / 1 km) = log (10).
/// - Parameter value: The value for which the logarithm needs to be calculated.
/// - Returns: The natural logarithm.
public func log(_ value: Measure) -> Measure {
    return try! Measure(log(value.scalarValue), unit: .one)
}


/// Returns the logarithm of base 10 for the specified value.
///
/// The unit of the result is the dimensionless unit `.one`.
/// The rationele behind this is that if the value of the argument does have a unit, one actually tries to
/// take the logarithm of the value divided by the unit of the value, e.g. log(10 km) = log(10 km / 1 km) = log (10).
/// - Parameter value: The value for which the logarithm needs to be calculated.
/// - Returns: The logarithm of base 10.
public func log10(_ value: Measure) -> Measure {
    return try! Measure(log10(value.scalarValue), unit: .one)
}


/// Returns the logarithm of base 2 for the specified value.
///
/// The unit of the result is the dimensionless unit `.one`.
/// The rationele behind this is that if the value of the argument does have a unit, one actually tries to
/// take the logarithm of the value divided by the unit of the value, e.g. log(10 km) = log(10 km / 1 km) = log(10).
/// - Parameter value: The value for which the logarithm needs to be calculated.
/// - Returns: The logarithm of base 2.
public func log2(_ value: Measure) -> Measure {
    return try! Measure(log2(value.scalarValue), unit: .one)
}

// MARK: Exponents

/// Returns the result of the natural exponential function e^x where e=2.71828... (Euler's number).
///
/// The unit of the result is the dimensionless unit `.one`. Normally the value of the argument would also
/// be dimensionless, but if the value of the argument does have a unit, one actually tries to
/// take the exponent of the value divided by the unit of the value e^(10 km) = e^(10 km / 1 km) = e^(10).
/// - Parameter value: The value for which the logarithm needs to be calculated.
/// - Returns: The result of the exponential function for the specified value.
public func exp(_ value: Measure) -> Measure {
    return try! Measure(exp(value.scalarValue), unit: .one)
}

// MARK: Trigonometric functions

/// Returns the sine of the specified angle. The angle should be in radians or one of its derived unit, such
/// as degrees, or arcseconds.
///
/// The result is a ``Measure`` with as unit the dimensionless unit `.one`.
/// - Parameter value: The angle.
/// - Returns: The sine of the angle.
public func sin(_ value: Angle) -> Measure {
    let valueInRadians = try! value.convert(to: .radian)
    return try! Measure(sin(valueInRadians.scalarValue), unit: .one)
}

/// Returns the cosine of the specified angle. The angle should be in radians or one of its derived unit, such
/// as degrees, or arcseconds.
///
/// The result is a ``Measure`` with as unit the dimensionless unit `.one`.
/// - Parameter value: The angle.
/// - Returns: The cosine of the angle.
public func cos(_ value: Angle) -> Measure {
    let valueInRadians = try! value.convert(to: .radian)
    return try! Measure(cos(valueInRadians.scalarValue), unit: .one)
}

/// Returns the tangent of the specified angle. The angle should be in radians or one of its derived unit, such
/// as degrees, or arcseconds.
///
/// If the argument is equal to `π`, the `scalarValue` of the result ``Measure`` will be
/// `Double.infinity`.
/// If the argument is equal to `-π`, the `scalarValue` of the result ``Measure`` will be
/// `-Double.infinity`.
///
/// The result is a ``Measure`` with as unit the dimensionless unit `.one`.
/// - Parameter value: The angle.
/// - Returns: The tangent of the angle.
public func tan(_ value: Angle) -> Measure {
    let valueInRadians = try! value.convert(to: .radian)
    if valueInRadians.scalarValue == Double.pi/2 {
        return try! Measure(Double.infinity, unit: .one)
    }
    if valueInRadians.scalarValue == -Double.pi/2 {
        return try! Measure(-Double.infinity, unit: .one)
    }
    return try! Measure(tan(valueInRadians.scalarValue), unit: .one)
}

/// Returns the arcsine (inverse sine) of the argument as an  ``Angle`` in the range [-π/2, π/2].
///
/// If the argument value is greater than `1.0` or smaller than `-1.0`, the `scalarValue` of the result
/// ``Measure`` will be equal to `Double.nan`.
///
/// The argument should be a dimensionless quantity but for ease of use dimensionfull arguments are
/// allowed as if the argument is devided by the unit of the quantiy,
/// e.g. asin(10 km) = asin(10 km / 1 km) = asin(10).
/// - Parameter value: The argument to the arcsine.
/// - Returns: The angle which is the result of taking the arcsine of the argument.
public func asin(_ value: Measure) -> Angle {
    return try! Angle(asin(value.scalarValue), unit: .radian)
}

/// Returns the arccosine (inverse cosine) of the argument as an  ``Angle`` in the range [0, 2π].
///
/// If the argument value is greater than `1.0` or smaller than `-1.0`, the `scalarValue` of the result
/// ``Measure`` will be equal to `Double.nan`. 
///
/// The argument should be a dimensionless quantity but for ease of use dimensionfull arguments are
/// allowed as if the argument is devided by the unit of the quantiy,
/// e.g. acos(10 km) = acos(10 km / 1 km) = acos(10).
/// - Parameter value: The argument to the arccosine.
/// - Returns: The angle which is the result of taking the arccosine of the argument.
public func acos(_ value: Measure) -> Angle {
    return try! Angle(acos(value.scalarValue), unit: .radian)
}

/// Returns the arctangent (inverse tangent) of the argument as an  ``Angle`` in the range [-π/2, π/2].
///
/// If the value of the argument is `Double.infinity`, the result will be an angle of π/2 and if the value of
/// the argument is `-Double.infinity`, the result will be an angle of -π/2 
///
/// The argument should be a dimensionless quantity but for ease of use dimensionfull arguments are
/// allowed as if the argument is devided by the unit of the quantiy,
/// e.g. atan(10 km) = atan(10 km / 1 km) = atan(10).
/// - Parameter value: The argument to the arctangent.
/// - Returns: The angle which is the result of taking the arctangent of the argument.
public func atan(_ value: Measure) -> Angle {
    return try! Angle(atan(value.scalarValue), unit: .radian)
}

/// Returns the arctangent (inverse tangent) of the division (numerator divided by the denominator of the two
/// arguments as an  ``Angle`` in the range [-π, π].
///
/// The arguments should have the same dimensions.
/// - Parameter value: The argument to the arctangent.
/// - Throws: if the dimensions of the `numerator` and `denominator` are not the same (as is
/// required) a ``UnitValidationError`` will be thrown.
/// - Returns: The angle which is the result of taking the arctangent of the argument.
public func atan(_ numerator: Measure, _ denominator: Measure) throws -> Angle {
    if numerator.dimensions != denominator.dimensions {
        throw UnitValidationError.differentDimensionality
    }
    return try! Angle(atan2(numerator.scalarValue, denominator.scalarValue), unit: .radian)
}

/// Returns the haversine of the specified angle. The angle should be in radians or one of its derived unit, such
/// as degrees, or arcseconds.
///
/// The result is a ``Measure`` with as unit the dimensionless unit `.one`.
/// - Parameter value: The angle.
/// - Returns: The haversine of the angle.
public func hav(_ value: Angle) -> Measure {
    let valueInRadians = (try! value.convert(to: .radian)).scalarValue
    let remainder = fabs(valueInRadians.truncatingRemainder(dividingBy: Double.pi))
    let split = 0.25*Double.pi
    if fabs(remainder) < split || fabs(remainder-Double.pi) < split {
        // Angle is closer to 0 or 180 degrees -> Use sin version as cos varies little near an angle of 0 or 180
        let hav = pow(sin(valueInRadians/2),2)
        return try! Measure(hav, unit: .one)
    } else {
        // Angle is closer to 90 or 270 degrees -> Use cos version as sin varies little near an angle of 0 or 180
        let hav = (1-cos(valueInRadians))/2
        return try! Measure(hav, unit: .one)
    }
}

/// Returns the archaversine (inverse haversine) of the argument as an  ``Angle`` in the range [0, 2π].
///
/// If the argument value is greater than `1.0` or smaller than `-1.0`, the `scalarValue` of the result
/// ``Measure`` will be equal to `Double.nan`.
///
/// The argument should be a dimensionless quantity but for ease of use dimensionfull arguments are
/// allowed as if the argument is devided by the unit of the quantiy,
/// e.g. ahav(10 km) = ahav(10 km / 1 km) = ahav(10).
/// - Parameter value: The argument to the archaversine.
/// - Returns: The angle which is the result of taking the archaversine of the argument.
public func ahav(_ value: Measure) -> Angle {
    let sinAngle = sqrt(value.scalarValue)
    if sinAngle < 0.1 {
        // Small angle approximation
        return try! Angle(sinAngle * 2, unit: .radian)
    }
    return try! Angle(asin(sinAngle) * 2, unit: .radian)
}
