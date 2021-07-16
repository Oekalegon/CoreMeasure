//
//  File.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

/// A `Measure` is a representation of a measurable value expressed in a specific unit or expressed on
/// a specific measurement scale.
///
/// It allows for comparisson and conversion between measures expressed in different units. One can, for
/// instance compare a height expressed in feet with a height expressed in centimetres.
///
/// Measures can also be added, subtracted, multiplied, or divided with each other. The unit in which the
/// result is expressed is adapted to the units of the arguments in the arithmetic expression. When dividing
/// measures, of different units, say `5 m` by `2 s`, the resulting value will be expressed in the
/// `UnitDivision` of the two units, i.e. `2.5 m/s`.
public class Measure : CustomStringConvertible {
    
    /// The scalar value of the measure as expressed in the specified unit or along the specified scale.
    public let scalarValue: Double
    
    /// The value of the measure as a `String`.
    ///
    /// In the case of a measure with a ``scalarValue``, this measure will be presented as the
    /// scalar value with the unit appended.
    /// In the case of a ``NominalScale`` or ``OrdinalScale``, this will be the label selected..
    public var stringValue: String {
        get {
            if labelInScale != nil {
                return labelInScale!
            }
            return self.description
        }
    }
    
    /// The selected label in a ``NominalScale`` or an ``OrdinalScale``.
    private let labelInScale: String?
    
    /// The unit in which the value of the measure is expressed.
    public let unit: Unit
    
    /// The scale along which the value of the measure is expressed.
    public let scale: Scale?
    
    /// The dimensions of the measure.
    public var dimensions: Dimensions {
        get {
            return unit.dimensions
        }
    }
    
    /// `true` when the measure is set along a scale.
    ///
    /// This is not necessarily a measurement scale, e.g. when the scale is a *nominal* or *ordinal*
    /// scale that is not ordered, or has no proportional intervals.
    public var usesScale : Bool {
        get {
            return scale != nil
        }
    }
    
    /// `true` when the measure is set along an ``IntervalScale`` or a ``RatioScale``.
    ///
    /// This value may still be `false` even when a scale is used, i.e. when the scale is a ``NominalScale``
    /// or an ``OrdinalScale`` that is not ordered, or has no proportional intervals.
    public var usesIntervalOrRatioScale : Bool {
        get {
            return scale != nil && ((scale as? IntervalScale) != nil || (scale as? RatioScale) != nil)
        }
    }
    
    /// Creates a new `Measure` with the specified scalar value and expessed in the specified
    /// unit.
    ///
    /// - Parameters:
    ///     - scalarValue: The scalar value of the `Measure`
    ///     - unit: The unit in which the scalar value is expressed.
    public init(_ scalarValue: Double, unit: Unit) throws {
        self.scalarValue = scalarValue
        self.unit = unit
        self.scale = nil
        self.labelInScale = nil
    }
    
    /// Creates a new `Measure` with the specified label value and in the specified nominal
    /// scale.
    ///
    /// If the specified label is not defined for the ``NominalScale``, a ``ScaleValidationError``
    /// will be thrown.
    /// - Parameters:
    ///   - label: The label selected from the nominal scale.
    ///   - scale: The  nominal scale.
    /// - Throws: a ``ScaleValidationError`` when the specified label is not defined for the
    /// ``NominalScale`` in its set of labels.
    public init(_ label: String, scale: NominalScale) throws {
        self.scalarValue = Double.nan
        self.unit = .one
        self.scale = scale
        self.labelInScale = label
        if !scale.labels.contains(label) {
            throw ScaleValidationError.unknownLabelForNominalOrOrdinalScale
        }
    }
    
    /// Creates a new `Measure` with the specified label value and in the specified ordinal
    /// scale.
    ///
    /// If the specified label is not defined for the ``OrdinalScale``, a ``ScaleValidationError``
    /// will be thrown.
    /// - Parameters:
    ///   - label: The label selected from the ordinal scale.
    ///   - scale: The  ordinal scale.
    /// - Throws: a ``ScaleValidationError`` when the specified label is not defined for the
    /// ``OrdinalScale`` in its set of labels.
    public init(_ label: String, scale: OrdinalScale) throws {
        self.scalarValue = Double.nan
        self.unit = .one
        self.scale = scale
        self.labelInScale = label
        if !scale.labels.contains(label) {
            throw ScaleValidationError.unknownLabelForNominalOrOrdinalScale
        }
    }
    
    /// Creates a new `Measure` with the specified scalar value and along the specified interval
    /// scale.
    ///
    /// - Parameters:
    ///     - scalarValue: The scalar value of the `Measure`
    ///     - scale: The scale in which the scalar value is placed.
    public init(_ scalarValue: Double, scale: IntervalScale) throws {
        self.scalarValue = scalarValue
        self.unit = scale.unit
        self.scale = scale
        self.labelInScale = nil
    }
    
    /// Creates a new `Measure` with the specified scalar value and along the specified ratio scale.
    ///
    /// Negative values are not allowed as a ratio scale defines an absolute zero.
    /// - Parameters:
    ///     - scalarValue: The scalar value of the `Measure`
    ///     - scale: The scale in which the scalar value is placed.
    public init(_ scalarValue: Double, scale: RatioScale) throws {
        if scalarValue < 0.0 {
            throw ScaleValidationError.negativeValuesNotAllowedInRatioScale
        }
        self.scalarValue = scalarValue
        self.unit = scale.unit
        self.scale = scale
        self.labelInScale = nil
    }
    
    /// Converts the `Measure` to the specified unit.
    ///
    /// If the current unit of the measure does not have the same dimensions the measure cannot be
    /// converted to the specified unit (e.g. you cannot convert a value expressed in metres to seconds as
    /// the result would be meaningless), a `UnitValidationError.differentDimensionality`
    /// will be thrown.
    ///
    /// If the current unit and the unit to which the measure needs to be converted to, do not have a
    /// common base unit, no conversion factor between the units can be calculated and a
    /// `UnitValidationError.noCommonBaseUnit` is thrown.
    ///
    /// If the measure is expressed relative to a scale, the measure can also not be converted to another
    /// unit as a specific unit is bound to a scale.
    /// A `ScaleValidationError.cannotConvertScaleToUnit` is thrown. If this is the case,
    /// you probably want to convert to another scale. For instance, you are not allowed to convert a
    /// temperature in the Celsius scale to the unit `.kelvin` as this measure would still be in the Celsius
    /// scale with the same zero point but with different units, i.e. `K`. You probably want to use the
    /// other method ``convert(to:)-k653`` with `.kelvinScale` as `scale`.
    ///
    /// - Parameters:
    ///     - unit: The unit to which the measure should be converted.
    /// - Throws: a ``UnitValidationError`` when the unit of the receiver has different
    ///     dimensions than the unit to which it needs to be converted, or when the unit of the receiver
    ///     and the specified unit have no common base unit.
    ///     A ``ScaleValidationError`` when the receiver is defined on a scale and, therefore,
    ///     can only be converted to another scale.
    /// - Returns: A new new measure with the value converted to the specified unit.
    public func convert(to unit: Unit) throws -> Measure {
        if self.unit.dimensions != unit.dimensions {
            throw UnitValidationError.differentDimensionality
        }
        if self.unit.baseUnit != unit.baseUnit {
            throw UnitValidationError.noCommonBaseUnit
        }
        if self.scale != nil {
            throw ScaleValidationError.cannotConvertScaleToUnit
        }
        let conversionFactor = self.unit.conversionFactor / unit.conversionFactor
        return try Measure(self.scalarValue*conversionFactor, unit: unit)
    }
    
    
    /// Converts the `Measure` to the specified scale.
    ///
    /// If the current scale of the measure does not have the same dimensions the measure cannot be
    /// converted to the specified scale (e.g. you cannot convert a value expressed in degrees Celsius to
    /// a stellar magnitude as the result would be meaningless), a
    /// `ScaleValidationError.differentDimensionality` will be thrown.
    ///
    /// If the current scale and the scale to which the measure needs to be converted to, do not have a
    /// common ratio scale, no offset between the scales can be calculated and a
    /// `ScaleValidationError.noCommonRatioScale` is thrown.
    ///
    /// If the unit of the current scale and the unit of the scale to which the measure needs to be converted
    /// to, do not have a common base unit, no conversion factor between the units can be calculated and
    /// a `UnitValidationError.noCommonBaseUnit` is thrown.
    ///
    /// If the measure is not expressed relative to a scale, the measure can  not be converted to a scale.
    /// A `UnitValidationError.cannotConvertUnitToScale` is thrown. If this is the case,
    /// you probably want to convert to another unit. For instance, you are not allowed to convert a
    /// temperature *difference* in the Celsius scale to the scale `.kelvinScale` as this measure
    /// is not expressed in relation to a specific scale (e.g. the `.celsiusScale`
    /// You probably want to use the other method ``convert(to:)-4qctn``  with `.kelvin`
    /// as `unit`. The result will then not bet expressed to a specific state but will be a temperature
    /// *difference*. just like the current `Measure`.
    ///
    /// - Parameters:
    ///     - scale: The scale to which the measure should be converted.
    /// - Throws: a ``UnitValidationError`` when a measure that is not related to any
    ///     scale is to be converted to a scale or when the scale of the receiver and the conversion
    ///     scale have incompatible units that have no common base unit.
    ///     A ``ScaleValidationError`` when the scale of the receiver.
    ///     does not have a common ratio scale with the specifed scale to which the meassure should be
    ///     converted to, or  If the dimensions of the scale of the receiver do not correspond to the
    ///     dimensions of the conversion scale.
    /// - Returns: A new new measure with the value converted to the specified scale.
    public func convert(to scale: Scale) throws -> Measure {
        if self.scale == nil {
            throw UnitValidationError.cannotConvertUnitToScale
        }
        if self.scale == scale {
            return self
        }
        if (self.scale as? NominalScale) != nil || (self.scale as? OrdinalScale) != nil ||
            (scale as? NominalScale) != nil  || (scale as? OrdinalScale) != nil {
            throw ScaleValidationError.cannotConvertToOrFromNominalOrOrdinalScale
        }
        let selfRatioScale = try self.ratioScale(for: self.scale!)
        let argumentRatioScale = try self.ratioScale(for: scale)
        if selfRatioScale != argumentRatioScale {
            throw ScaleValidationError.noCommonRatioScale
        }
        if selfRatioScale.dimensions != argumentRatioScale.dimensions {
            throw ScaleValidationError.differentDimensionality
        }
        if selfRatioScale.unit.baseUnit != argumentRatioScale.unit.baseUnit {
            throw UnitValidationError.noCommonBaseUnit
        }
        var mtemp = self
        if self.scale != selfRatioScale && scale != selfRatioScale {
            mtemp = try self.convert(to: selfRatioScale)
            if mtemp.scale != scale {
                mtemp = try mtemp.convert(to: scale)
                return mtemp
            }
        }
        if scale == argumentRatioScale { // Convert to ratio scale
            let intervalScale = self.scale as! IntervalScale
            if intervalScale.offset == nil {
                throw ScaleValidationError.notLinkedToARatioScale
            }
            return try Measure((self.scalarValue-intervalScale.offset!.scalarValue)*self.unit.conversionFactor, scale: selfRatioScale)
        }
        // Convert from ratio scale
        let intervalScale = scale as! IntervalScale
        if intervalScale.offset == nil {
            throw ScaleValidationError.notLinkedToARatioScale
        }
        return try Measure(self.scalarValue/intervalScale.unit.conversionFactor+intervalScale.offset!.scalarValue, scale: intervalScale)
    }
    
    private func ratioScale(for scale: Scale) throws -> RatioScale {
        var ratioScale : RatioScale
        if (scale as? RatioScale) != nil {
            ratioScale = (scale as! RatioScale)
        } else if (scale as? IntervalScale) != nil {
            if (scale as! IntervalScale).ratioScale == nil {
                throw ScaleValidationError.notLinkedToARatioScale
            }
            ratioScale = (scale as! IntervalScale).ratioScale!
        } else {
            throw ScaleValidationError.notLinkedToARatioScale
        }
        return ratioScale
    }
    
    /// Returns a string description of the measure in the form of the scalar value followed by a space and
    /// the symbol for the unit e.g. `12.3 kg/m`.
    ///
    /// NB. Values for `Measure`s on a scale will be expressed in the same way.
    public var description: String {
        get {
            if (unit as? CompoundUnit) != nil {
                let components = componentsForCompoundUnit(for: (unit as! CompoundUnit).partialUnits, value: self)
                var str = ""
                if components.sign > 0 {
                    if (unit as! CompoundUnit).displaySign {
                        str = "+"
                    }
                } else if components.sign < 0 {
                    str = "-"
                }
                var spacer = ""
                for component in components.components {
                    let intValue = Int(component.measure.scalarValue)
                    let cunit = component.measure.unit
                    var digitStr = ""
                    if component.ndigits > 0 {
                        for _ in 0..<component.ndigits {
                            digitStr = "\(digitStr)0"
                        }
                    }
                    if cunit == .degree || cunit == .arcminute || cunit == .arcsecond || cunit == .angleHour || cunit == .angleMinute || cunit == .angleSecond {
                        str = "\(str)\(spacer)\(digitStr)\(intValue)\(cunit.symbol)"
                    } else {
                        str = "\(str)\(spacer)\(digitStr)\(intValue)\(cunit.symbol)"
                    }
                    str = str.trimmingCharacters(in: .whitespaces)
                    spacer = " "
                }
                return str
            }
            if unit == .degree || unit == .arcminute || unit == .arcsecond || unit == .angleHour || unit == .angleMinute || unit == .angleSecond {
                return "\(scalarValue)\(unit.symbol)"
            }
            return "\(scalarValue) \(unit.symbol)"
        }
    }
    
    private func componentsForCompoundUnit(for compoundUnits: [Unit], position: Int = 0, value: Measure) -> (sign: Int16, components: [(measure: Measure, ndigits: Int, nfraction: Int)]) {
        var components = [(measure: Measure, ndigits: Int, nfraction: Int)]()
        var roundingFactor = 0.0
        var measure = value
        var sign : Int16 = 1
        if position == 0 {
            let smallestUnit = compoundUnits.last!
            var roundingFactorMeasure = try! Measure(0.5, unit: smallestUnit)
            roundingFactorMeasure = try! roundingFactorMeasure.convert(to: value.unit)
            roundingFactor = roundingFactorMeasure.scalarValue
            var scalarValue = value.scalarValue
            if scalarValue < 0 {
                sign = -1
                scalarValue = -scalarValue
            }
            measure = try! Measure(scalarValue+roundingFactor, unit: value.unit)
        }
        if compoundUnits.count > position {
            let converted = try! measure.convert(to: compoundUnits[position])
            // get number of digits
            var ndigits = 0
            if position > 0 {
                let testm = try! Measure(1.0, unit:compoundUnits[position-1])
                let maxm = try! testm.convert(to: compoundUnits[position])
                ndigits = Int(log10(maxm.scalarValue))+1
            }
            let rounded = try! Measure(Double(Int(converted.scalarValue)), unit: converted.unit)
            var digits = ndigits - 1
            if rounded.scalarValue > 0.0 {
                digits = ndigits - Int(log10(rounded.scalarValue))-1
            }
            let difference = try! converted - rounded
            components.append((measure: rounded, ndigits: digits, nfraction: 0))
            components.append(contentsOf: self.componentsForCompoundUnit(for: compoundUnits, position: position+1, value: difference).components)
        }
        return (sign: sign, components: components)
    }
}

extension Measure: Equatable {
    
    /// Compares the left hand `Measure` with the right hand `Measure` and returns `true` when
    /// they are equal.
    ///
    /// If the measures are not expressed in the same unit, or relative to the same scale. the right hand
    /// measure will first be converted to the unit or scale of the left hand measure.
    ///
    /// If the right hand measure cannot be converted to the same unit ior scale as the left hand measure
    /// `false` will be returned. (See `convert(to unit: Unit)` and
    /// `convert(to scale: Scale)` for condition when the measure cannot be converted.
    public static func == (lhs: Measure, rhs: Measure) -> Bool {
        if (lhs.scale == nil && rhs.scale != nil) || (lhs.scale != nil && rhs.scale == nil)  {
            return false
        }
        if lhs.scale != nil && rhs.scale != nil {
            if lhs.scale != rhs.scale {
                do {
                    let converted = try rhs.convert(to: lhs.scale!)
                    return lhs == converted
                } catch {
                    return false
                }
            }
            if lhs.labelInScale != nil { // is a nominal or ordinal scale
                if lhs.labelInScale == rhs.labelInScale {
                    return true
                }
                return false
            }
        }
        if lhs.unit == rhs.unit && lhs.scalarValue == rhs.scalarValue {
            return true
        }
        if lhs.unit == rhs.unit && lhs.scalarValue != rhs.scalarValue {
            return false
        }
        do {
            let converted = try rhs.convert(to: lhs.unit)
            return lhs == converted
        } catch {
            return false
        }
    }
}


// MARK: Comparing Measures

/// Returns `true` when the measure on the left hand side is greater than the measure on the
/// right hand side.
///
/// If the left and right hand side are not expressed in the same unts or scale, the right hand side measure
/// will be  converted to the same unit or scale as the left hand side to be able to be compared.
/// If the measure on the right hand side cannot be converted to the same unit or scale, `false` will be
/// returned.
///
/// **This means that both `a >= b` and `a <= b` can return `false` if the measures cannot
/// be converted to each other.**
///
///  - Parameters:
///     - lhs: The left hand side measure in the comparisson.
///     - rhs: The right hand side value in the comparisson.
///  - Returns: `true` when the left hand side is greater than the right hand side, or `false`
///  otherwise.
public func >(lhs: Measure, rhs: Measure) -> Bool {
    if lhs.usesScale || rhs.usesScale {
        if lhs.usesIntervalOrRatioScale && rhs.usesIntervalOrRatioScale {
            let converted = try? rhs.convert(to: lhs.scale!)
            if converted == nil {
                return false
            }
            return lhs.scalarValue > converted!.scalarValue
        }
        if (lhs.scale as? OrdinalScale) != nil && rhs.scale == lhs.scale {
            let lIndex = (lhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            let rIndex = (rhs.scale as! OrdinalScale).labels.firstIndex(of: rhs.stringValue)!
            return lIndex > rIndex
        }
        return false
    }
    let converted = try? rhs.convert(to: lhs.unit)
    if converted == nil {
        return false
    }
    return lhs.scalarValue > converted!.scalarValue
}

/// Returns `true` when the measure on the left hand side is greater than or equal to the measure on the
/// right hand side.
///
/// If the left and right hand side are not expressed in the same unts or scale, the right hand side measure
/// will be  converted to the same unit or scale as the left hand side to be able to be compared.
/// If the measure on the right hand side cannot be converted to the same unit or scale, `false` will be
/// returned.
///
/// **This means that both `a >= b` and `a <= b` can return `false` if the measures cannot
/// be converted to each other.**
///
///  - Parameters:
///     - lhs: The left hand side measure in the comparisson.
///     - rhs: The right hand side value in the comparisson.
///  - Returns: `true` when the left hand side is greater than or equal to the right hand side, or
///  `false` otherwise.
public func >=(lhs: Measure, rhs: Measure) -> Bool {
    if lhs.usesScale || rhs.usesScale {
        if lhs.usesIntervalOrRatioScale && rhs.usesIntervalOrRatioScale {
            let converted = try? rhs.convert(to: lhs.scale!)
            if converted == nil {
                return false
            }
            return lhs.scalarValue >= converted!.scalarValue
        }
        if (lhs.scale as? OrdinalScale) != nil && rhs.scale == lhs.scale {
            let lIndex = (lhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            let rIndex = (rhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            return lIndex >= rIndex
        }
        return false
    }
    let converted = try? rhs.convert(to: lhs.unit)
    if converted == nil {
        return false
    }
    return lhs.scalarValue >= converted!.scalarValue
}


// MARK: Comparing Measures

/// Returns `true` when the measure on the left hand side is smaller than the measure on the
/// right hand side.
///
/// If the left and right hand side are not expressed in the same unts or scale, the right hand side measure
/// will be  converted to the same unit or scale as the left hand side to be able to be compared.
/// If the measure on the right hand side cannot be converted to the same unit or scale, `false` will be
/// returned.
///
/// **This means that both `a >= b` and `a <= b` can return `false` if the measures cannot
/// be converted to each other.**
///
///  - Parameters:
///     - lhs: The left hand side measure in the comparisson.
///     - rhs: The right hand side value in the comparisson.
///  - Returns: `true` when the left hand side is smaller than the right hand side, or `false`
///  otherwise.
public func <(lhs: Measure, rhs: Measure) -> Bool {
    if lhs.usesScale || rhs.usesScale {
        if lhs.usesIntervalOrRatioScale && rhs.usesIntervalOrRatioScale {
            let converted = try? rhs.convert(to: lhs.scale!)
            if converted == nil {
                return false
            }
            return lhs.scalarValue < converted!.scalarValue
        }
        if (lhs.scale as? OrdinalScale) != nil && rhs.scale == lhs.scale {
            let lIndex = (lhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            let rIndex = (rhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            return lIndex < rIndex
        }
        return false
    }
    let converted = try? rhs.convert(to: lhs.unit)
    if converted == nil {
        return false
    }
    return lhs.scalarValue < converted!.scalarValue
}

/// Returns `true` when the measure on the left hand side is smaller than or equal to the measure on the
/// right hand side.
///
/// If the left and right hand side are not expressed in the same unts or scale, the right hand side measure
/// will be  converted to the same unit or scale as the left hand side to be able to be compared.
/// If the measure on the right hand side cannot be converted to the same unit or scale, `false` will be
/// returned.
///
/// **This means that both `a >= b` and `a <= b` can return `false` if the measures cannot
/// be converted to each other.**
///
///  - Parameters:
///     - lhs: The left hand side measure in the comparisson.
///     - rhs: The right hand side value in the comparisson.
///  - Returns: `true` when the left hand side is smaller than or equal to the right hand side, or
///  `false` otherwise.
public func <=(lhs: Measure, rhs: Measure) -> Bool {
    if lhs.usesScale || rhs.usesScale {
        if lhs.usesIntervalOrRatioScale && rhs.usesIntervalOrRatioScale {
            let converted = try? rhs.convert(to: lhs.scale!)
            if converted == nil {
                return false
            }
            return lhs.scalarValue <= converted!.scalarValue
        }
        if (lhs.scale as? OrdinalScale) != nil && rhs.scale == lhs.scale {
            let lIndex = (lhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            let rIndex = (rhs.scale as! OrdinalScale).labels.firstIndex(of: lhs.stringValue)!
            return lIndex <= rIndex
        }
        return false
    }
    let converted = try? rhs.convert(to: lhs.unit)
    if converted == nil {
        return false
    }
    return lhs.scalarValue <= converted!.scalarValue
}
