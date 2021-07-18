//
//  File.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public enum MeasureDisplayComponentType {
    case plus
    case minus
    case value
    case space
    case unitSymbol
    case unitDivider
    case unitExponent
    case plusMinus
    case errorValue
    case times
    case tenPower
    case tenExponent
    case scaleLabel
}

public enum Baseline {
    case normal
    case sup
    case sub
}

public struct MeasureDisplayComponent {
    
    public let type: MeasureDisplayComponentType
    public let displayString: String
    public let baseline: Baseline
    
    public init(type: MeasureDisplayComponentType, displayString: String? = nil, baseline: Baseline = .normal) {
        self.type = type
        self.baseline = baseline
        switch type {
        case .space:
            self.displayString = " "
        case .plus:
            self.displayString = "+"
        case .minus:
            self.displayString = "-"
        case .unitDivider:
            self.displayString = "/"
        case .plusMinus:
            self.displayString = "±"
        case .times:
            self.displayString = "⨉"
        case .tenPower:
            self.displayString = "10"
        default:
            self.displayString = (displayString != nil) ? displayString! : ""
        }
    }
}

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
    
    /// The error on the scalar value.
    ///
    /// If the error is not known, set the ``error`` to `nil`.
    public let error: Double?
    
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
    ///    - scalarValue: The scalar value of the `Measure`
    ///    - error: The error on the scalar value: Set to `nil` if the error is not known.
    ///    - unit: The unit in which the scalar value is expressed.
    public init(_ scalarValue: Double, error: Double? = nil, unit: Unit) throws {
        self.scalarValue = scalarValue
        if error != nil && error! <= 0 {
            throw MeasureValidationError.nonPositiveError
        }
        self.error = error
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
        self.error = nil
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
        self.error = nil
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
    ///    - scalarValue: The scalar value of the `Measure`
    ///    - error: The error on the scalar value: Set to `nil` if the error is not known.
    ///    - scale: The scale in which the scalar value is placed.
    public init(_ scalarValue: Double, error: Double? = nil, scale: IntervalScale) throws {
        self.scalarValue = scalarValue
        if error != nil && error! <= 0 {
            throw MeasureValidationError.nonPositiveError
        }
        self.error = error
        self.unit = scale.unit
        self.scale = scale
        self.labelInScale = nil
    }
    
    /// Creates a new `Measure` with the specified scalar value and along the specified ratio scale.
    ///
    /// Negative values are not allowed as a ratio scale defines an absolute zero.
    /// - Parameters:
    ///    - scalarValue: The scalar value of the `Measure`
    ///    - error: The error on the scalar value: Set to `nil` if the error is not known.
    ///    - scale: The scale in which the scalar value is placed.
    public init(_ scalarValue: Double, error: Double? = nil, scale: RatioScale) throws {
        if scalarValue < 0.0 {
            throw ScaleValidationError.negativeValuesNotAllowedInRatioScale
        }
        self.scalarValue = scalarValue
        if error != nil && error! <= 0 {
            throw MeasureValidationError.nonPositiveError
        }
        self.error = error
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
    ///    - unit: The unit to which the measure should be converted.
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
        return try Measure(self.scalarValue*conversionFactor, error: (self.error != nil) ? self.error!*conversionFactor: nil, unit: unit)
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
    ///    - scale: The scale to which the measure should be converted.
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
            return try Measure((self.scalarValue-intervalScale.offset!.scalarValue)*self.unit.conversionFactor,
                               error: (self.error != nil) ? (self.error!-intervalScale.offset!.scalarValue)*self.unit.conversionFactor : nil,
                               scale: selfRatioScale)
        }
        // Convert from ratio scale
        let intervalScale = scale as! IntervalScale
        if intervalScale.offset == nil {
            throw ScaleValidationError.notLinkedToARatioScale
        }
        return try Measure(self.scalarValue/intervalScale.unit.conversionFactor+intervalScale.offset!.scalarValue,
                           error: (self.error != nil) ? self.error!/intervalScale.unit.conversionFactor+intervalScale.offset!.scalarValue : nil,
                           scale: intervalScale)
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
            let components = self.componentsForDisplay
            var str=""
            for component in components {
                if component.type != .plus {
                    str = "\(str)\(component.displayString)"
                }
                if component.type == .tenPower {
                    str = "\(str)^"
                }
            }
            return str
        }
    }
    
    public var componentsForDisplay : [MeasureDisplayComponent] {
        get {
            var display = [MeasureDisplayComponent]()
            if self.scalarValue.isNaN {
                display.append(MeasureDisplayComponent(type: .value, displayString: "NaN"))
            } else if self.scalarValue.isInfinite {
                if self.scalarValue == -Double.infinity {
                    display.append(MeasureDisplayComponent(type: .value, displayString: "-∞"))
                } else {
                    display.append(MeasureDisplayComponent(type: .value, displayString: "∞"))
                }
            } else if self.usesScale && !self.usesIntervalOrRatioScale {
                display.append(MeasureDisplayComponent(type: .scaleLabel, displayString: self.stringValue))
            } else if (unit as? CompoundUnit) != nil {
                let compoundUnit = unit as! CompoundUnit
                var value = fabs(self.scalarValue)
                if self.scalarValue > 0 && compoundUnit.displaySign {
                    display.append(MeasureDisplayComponent(type: .plus))
                } else if self.scalarValue < 0 {
                    display.append(MeasureDisplayComponent(type: .minus))
                }
                var error: Double
                if self.error != nil {
                    error = self.error!
                } else { // no error set -> use an error of 1 <smallest-unit>
                    error = (try! Measure(1.0, unit: compoundUnit.partialUnits.last!).convert(to: self.unit)).scalarValue
                }
                value = round(1/error * value) * error // Rounding to the error
                var previousUnit : Unit? = nil
                for componentUnit in compoundUnit.partialUnits {
                    var tempmes = try! Measure(value, error: error, unit: self.unit)
                    tempmes = try! tempmes.convert(to: componentUnit)
                    var inttempmes = try! Measure(Double(Int(tempmes.scalarValue)), unit: componentUnit)
                    if tempmes.error! >= 1.0 {
                        inttempmes = try! Measure(round(tempmes.scalarValue), unit: componentUnit)
                    }
                    var valueString = "\(Int(inttempmes.scalarValue))"
                    if previousUnit != nil {
                        let testMeasure = try! Measure(1.0, unit: previousUnit!).convert(to: componentUnit)
                        let nrdigits = Int(log10(testMeasure.scalarValue)) + 1 - valueString.count
                        for _ in 0..<nrdigits {
                            valueString = "0\(valueString)"
                        }
                    }
                    previousUnit = componentUnit
                    display.append(MeasureDisplayComponent(type: .value, displayString: valueString))
                    display.append(contentsOf: Measure.unitComponentForDisplay(unit: componentUnit))
                    if tempmes.error! >= 1.0 {
                        break
                    }
                    tempmes = try! inttempmes.convert(to: self.unit)
                    value = value - tempmes.scalarValue
                    if compoundUnit != compoundUnit.partialUnits.last {
                        display.append(MeasureDisplayComponent(type: .space))
                    }
                }
                if self.error != nil {
                    display.append(MeasureDisplayComponent(type: .space))
                    var selectedMeasure : Measure? = nil
                    for errorUnit in compoundUnit.errorUnits {
                        var errorMeasure = try! Measure(self.error!, error: self.error!, unit: self.unit)
                        errorMeasure = try! errorMeasure.convert(to: errorUnit)
                        var testError = 1.0
                        if errorMeasure.scalarValue < 1.0 {
                            let logerror = Double(Int(log10(errorMeasure.scalarValue)))
                            testError = pow(10.0, logerror)
                        }
                        selectedMeasure = try! Measure(errorMeasure.scalarValue, error: testError, unit: errorUnit)
                        if selectedMeasure!.scalarValue >= 1.0 || errorUnit == compoundUnit.errorUnits.last! {
                            let errorDisplay = selectedMeasure!.componentsForDisplay
                            for item in errorDisplay {
                                if item.type == .value {
                                    display.append(MeasureDisplayComponent(type: .plusMinus))
                                    display.append(MeasureDisplayComponent(type: .errorValue, displayString: item.displayString))
                                }
                                if item.type == .tenExponent {
                                    display.append(MeasureDisplayComponent(type: .space))
                                    display.append(MeasureDisplayComponent(type: .times))
                                    display.append(MeasureDisplayComponent(type: .space))
                                    display.append(MeasureDisplayComponent(type: .tenPower))
                                    display.append(MeasureDisplayComponent(type: .tenExponent, displayString: item.displayString))
                                }
                            }
                            display.append(contentsOf: Measure.unitComponentForDisplay(unit: errorUnit))
                            break
                        }
                    }
                }
            } else {
                let valueError = Measure.roundByError(value: scalarValue, error: error)
                if scalarValue < 0 {
                    display.append(MeasureDisplayComponent(type: .minus))
                }
                display.append(MeasureDisplayComponent(type: .value, displayString: valueError.number))
                if valueError.error != nil {
                    display.append(MeasureDisplayComponent(type: .space))
                    display.append(MeasureDisplayComponent(type: .plusMinus))
                    display.append(MeasureDisplayComponent(type: .errorValue, displayString: valueError.error!))
                }
                if valueError.exponent != 0 {
                    display.append(MeasureDisplayComponent(type: .space))
                    display.append(MeasureDisplayComponent(type: .times))
                    display.append(MeasureDisplayComponent(type: .space))
                    display.append(MeasureDisplayComponent(type: .tenPower))
                    display.append(MeasureDisplayComponent(type: .tenExponent, displayString: "\(valueError.exponent)"))
                }
                display.append(contentsOf: Measure.unitComponentForDisplay(unit: self.unit))
            }
            return display
        }
    }
    
    private static func unitComponentForDisplay(unit: Unit) -> [MeasureDisplayComponent] {
        var display = [MeasureDisplayComponent]()
        if unit != .degree && unit != .arcminute && unit != .arcsecond && unit != .angleHour && unit != .angleMinute && unit != .angleSecond {
            display.append(MeasureDisplayComponent(type: .space))
        }
        if unit == .angleHour || unit == .angleMinute || unit == .angleSecond {
            display.append(MeasureDisplayComponent(type: .unitSymbol, displayString: unit.symbol, baseline: .sup))
        } else if unit.symbol.count > 0 {
            display.append(MeasureDisplayComponent(type: .unitSymbol, displayString: unit.symbol))
        }
        return display
    }
    
    private static func roundByError(value: Double, error: Double?) -> (number: String, error: String?, exponent: Int) {
        let absvalue = fabs(value)
        var logvalue = 0
        if absvalue > 0 {
            logvalue = Int(log10(absvalue))
        }
        if absvalue < 1.0 {
            logvalue = logvalue-1
        }
        var exponent = 0
        var displayNumber = absvalue
        var displayNumberString = ""
        var displayErrorString : String? = nil
        if error == nil || error! <= 0 {
            if logvalue < -3 || logvalue > 3 {
                exponent = logvalue
                let expmultiplier = pow(10,Double(-logvalue))
                let expvalue = expmultiplier*absvalue
                let multiplier = pow(10, 9.0)
                displayNumber = round(multiplier*expvalue)/multiplier
            }
            displayNumberString = "\(displayNumber)"
        } else {
            var displayError = error!
            var logerror = Int(log10(error!))
            if error! < 1.0 {
                logerror = logerror-1
            }
            if logvalue >= 0 && logerror == 0 { // value >= 1 and error >=1 <10 -> 123±2
                exponent = 0
                let multiplier = pow(10, Double(-logerror))
                displayNumber = Double(round(multiplier*absvalue)/multiplier)
                displayError = Double(round(multiplier*error!)/multiplier)
                displayNumberString = "\(Int(displayNumber))"
                displayErrorString = "\(Int(displayError))"
            } else if logvalue >= 0 && logerror < 0 { // value >= 1 and error < 1 -> 123.2±0.3
                exponent = 0
                let multiplier = pow(10, Double(-logerror))
                displayNumber = Double(round(multiplier*absvalue)/multiplier)
                displayError = Double(round(multiplier*error!)/multiplier)
                displayNumberString = "\(displayNumber)"
                displayErrorString = "\(displayError)"
            } else if logvalue >= 0 && logerror > 0 { // value >= 1 and error > 10 -> 1.2±0.3x10^2
                exponent = logvalue
                let expmultiplier = pow(10,Double(-logvalue))
                let expvalue = expmultiplier*absvalue
                let experror = expmultiplier*error!
                let multiplier = pow(10, Double(exponent-logerror))
                displayNumber = Double(round(multiplier*expvalue)/multiplier)
                displayError = Double(round(multiplier*experror)/multiplier)
                displayNumberString = "\(displayNumber)"
                displayErrorString = "\(displayError)"
            } else { // value < 1 and error < 1 -> 1.2±0.3x10^-2
                exponent = logvalue
                let expmultiplier = pow(10,Double(-logvalue))
                let expvalue = expmultiplier*absvalue
                let experror = expmultiplier*error!
                let multiplier = pow(10, Double(exponent-logerror))
                displayNumber = Double(round(multiplier*expvalue)/multiplier)
                displayError = Double(round(multiplier*experror)/multiplier)
                displayNumberString = "\(displayNumber)"
                displayErrorString = "\(displayError)"
            }
        }
        
        return (number: displayNumberString, error: displayErrorString, exponent: exponent)
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
