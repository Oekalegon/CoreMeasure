//
//  Unit.swift
//  
//
//  Created by Don Willems on 05/07/2021.
//

import Foundation

public class OMUnit : Equatable, Hashable,
                    StringDisplayComponentsProvider,
                    CustomStringConvertible{
    
    public let identifier: String
    public var symbol: String {
        get {
            if _symbol != nil {
                return _symbol!
            } else {
                return self.description
            }
        }
    }
    
    fileprivate let _symbol: String?
    public let dimensions: Dimensions
    public fileprivate(set) var isBaseUnit: Bool = false
    private var _baseUnit: OMUnit?
    public fileprivate(set) var baseUnit : OMUnit {
        get {
            if _baseUnit == nil {
                return self
            }
            return _baseUnit!
        }
        set(newValue) {
            _baseUnit = newValue
            self.unitExponents = _baseUnit!.unitExponents
            if _baseUnit == nil {
                self.isBaseUnit = true
            }
        }
    }
    public fileprivate(set) var conversionFactor: Double
 
    public var componentsForDisplay: [StringDisplayComponent] {
        get {
            return [StringDisplayComponent(type: .unitSymbol, displayString: self.symbol)]
        }
    }
    
    public var description: String {
        get {
            var str=""
            let components = self.componentsForDisplay
            for component in components {
                if component.type == .unitExponent {
                    str = "\(str)^"
                }
                str = "\(str)\(component.displayString)"
            }
            return str
        }
    }
    
    internal var unitExponents: [(unit: OMUnit, exponent: Double)] = [(unit: OMUnit, exponent: Double)]()
    
    internal var baseUnitsPerDimension = [Dimension: [OMUnit: Double]]()
    
    public convenience init(symbol: String) {
        let dimensions = Dimensions()
        self.init(symbol: symbol, dimensions: dimensions)
        self.isBaseUnit = true
        self.unitExponents = [(unit: self, exponent: 1)]
    }
    
    public convenience init(symbol: String, dimension: Dimension) {
        let dimensions = Dimensions([dimension: 1])
        self.init(symbol: symbol, dimensions: dimensions)
        self.isBaseUnit = true
        self.baseUnitsPerDimension[dimension] = [self: 1]
        self.unitExponents = [(unit: self, exponent: 1)]
    }
    
    fileprivate init(symbol: String?, baseUnit: OMUnit, conversionFactor: Double = 1.0, identifier: String = UUID().uuidString) {
        self.identifier = identifier
        self._baseUnit = baseUnit.baseUnit
        self.conversionFactor = conversionFactor
        self._symbol = symbol
        self.dimensions = baseUnit.dimensions
        self.baseUnitsPerDimension = baseUnit.baseUnitsPerDimension
        isBaseUnit = false
        self.unitExponents = baseUnit.unitExponents
    }
    
    internal init(symbol: String?, dimensions: Dimensions, identifier: String = UUID().uuidString) {
        self.identifier = identifier
        self.conversionFactor = 1.0
        self._symbol = symbol
        self.dimensions = dimensions
        isBaseUnit = true
        self.unitExponents = [(unit: self, exponent: 1)]
    }
    
    internal func uniExponentsAdd(unit: OMUnit, exponent: Double) {
        for unitEuTuple in unit.unitExponents {
            var found = false
            var pos = 0
            for eutuple in unitExponents {
                if eutuple.unit == unitEuTuple.unit {
                    let exp = eutuple.exponent
                    unitExponents.remove(at: pos)
                    unitExponents.insert((unit: unit, exponent: exp + exponent), at: pos)
                    found = true
                }
                pos = pos + 1
            }
            if !found {
                unitExponents.append((unit: unitEuTuple.unit, exponent: unitEuTuple.exponent * exponent))
            }
        }
        unitExponents.sort(by: {$0.exponent > $1.exponent})
    }
    
    internal func uniExponentsMultiply(unit: OMUnit, exponent: Double) {
        for unitEuTuple in unit.unitExponents {
            var found = false
            var pos = 0
            for eutuple in unitExponents {
                if eutuple.unit == unitEuTuple.unit {
                    let exp = eutuple.exponent
                    unitExponents.remove(at: pos)
                    unitExponents.insert((unit: unit, exponent: exp * exponent), at: pos)
                    found = true
                }
                pos = pos + 1
            }
            if !found {
                unitExponents.append((unit: unitEuTuple.unit, exponent: unitEuTuple.exponent * exponent))
            }
        }
        unitExponents.sort(by: {$0.exponent > $1.exponent})
    }
    
    // Changes 100.0 to 100 and 100.1233100001 to 100.12331
    fileprivate static func findMultipleUsedInSymbol(factor: Double, from exponent: Int = 0) -> String {
        let absFactor = fabs(factor)
        let sign = factor < 0.0 ? "-" : ""
        let exp1 : Double = pow(10.0, Double(exponent))
        let diff = fabs(absFactor * exp1 - Double(Int(absFactor * exp1 + 0.5)))
        if diff > 0.001 {
            return "\(sign)\(findMultipleUsedInSymbol(factor: absFactor, from: exponent + 1))"
        }
        if exponent == 0 {
            return "\(sign)\(Int(absFactor))"
        }
        return "\(sign)\(Double(Int(absFactor * exp1))/exp1)"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: OMUnit, rhs: OMUnit) -> Bool {
        if lhs.identifier == rhs.identifier {
            return true
        }
        if lhs.dimensions != rhs.dimensions {
            return false
        }
        if lhs.conversionFactor != rhs.conversionFactor {
            return false
        }
        for dim in Dimension.allCases {
            var unitsInDimLHS = lhs.baseUnitsPerDimension[dim]
            var unitsInDimRHS = rhs.baseUnitsPerDimension[dim]
            if unitsInDimLHS == nil {
                unitsInDimLHS = [OMUnit: Double]()
            }
            if unitsInDimRHS == nil {
                unitsInDimRHS = [OMUnit: Double]()
            }
            for (unit, exponent) in unitsInDimLHS! {
                let exp2 = unitsInDimRHS![unit]
                if exp2 == nil || exp2! != exponent {
                    return false
                }
            }
            for (unit, exponent) in unitsInDimRHS! {
                let exp2 = unitsInDimLHS![unit]
                if exp2 == nil || exp2! != exponent {
                    return false
                }
            }
        }
        return true
    }
}

public class EquivalentUnit : OMUnit {
    
    public let unit: OMUnit
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            return [StringDisplayComponent(type: .unitSymbol, displayString: self.symbol)]
        }
    }
    
    public init(symbol: String, equivalent unit: OMUnit) {
        self.unit = unit
        super.init(symbol: symbol, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor)
        self.unitExponents = [(unit: self, exponent: 1)]
    }
}

public struct Prefix {
    
    public static let yotta = Prefix(symbol:"Y", factor:pow(10,24))
    public static let zetta = Prefix(symbol:"Z", factor:pow(10,21))
    public static let exa = Prefix(symbol:"E", factor:pow(10,18))
    public static let peta = Prefix(symbol:"P", factor:pow(10,15))
    public static let tera = Prefix(symbol:"T", factor:pow(10,12))
    public static let giga = Prefix(symbol:"G", factor:pow(10,9))
    public static let mega = Prefix(symbol:"M", factor:pow(10,6))
    public static let kilo = Prefix(symbol:"k", factor:1000.0)
    public static let hecto = Prefix(symbol:"h", factor:100.0)
    public static let deca = Prefix(symbol:"da", factor:10.0)
    public static let deci = Prefix(symbol:"d", factor:0.1)
    public static let centi = Prefix(symbol:"c", factor:0.01)
    public static let milli = Prefix(symbol:"m", factor:0.001)
    public static let micro = Prefix(symbol:"μ", factor:pow(10,-6))
    public static let nano = Prefix(symbol:"n", factor:pow(10,-9))
    public static let pico = Prefix(symbol:"p", factor:pow(10,-12))
    public static let femto = Prefix(symbol:"f", factor:pow(10,-15))
    public static let atto = Prefix(symbol:"a", factor:pow(10,-18))
    public static let zepto = Prefix(symbol:"z", factor:pow(10,-21))
    public static let yocto = Prefix(symbol:"y", factor:pow(10,-24))
    
    public let symbol: String
    public let factor: Double
    
    private init(symbol: String, factor: Double) {
        self.symbol = symbol
        self.factor = factor
    }
}

public class PrefixedUnit : OMUnit {
    
    public let prefix: Prefix
    public let unit: OMUnit
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            if self._symbol != nil {
                return [StringDisplayComponent(type: .unitSymbol, displayString: self._symbol)]
            }
            return [StringDisplayComponent(type: .unitPrefix, displayString: prefix.symbol),
                    StringDisplayComponent(type: .unitSymbol, displayString: unit.symbol)]
        }
    }
    
    public convenience init(symbol: String? = nil, prefix: Prefix, unit: OMUnit) {
        self.init(symbol: symbol, prefix:prefix, unit:unit, isBaseUnit: false)
    }
    
    internal init(symbol: String? = nil, prefix: Prefix, unit: OMUnit, isBaseUnit: Bool) {
        self.prefix = prefix
        self.unit = unit
        super.init(symbol: symbol, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor*prefix.factor, identifier: "[\(prefix.symbol)]\(unit.identifier)")
        if isBaseUnit {
            self.isBaseUnit = true
            unit.isBaseUnit = false
            unit.baseUnit = self
            unit.conversionFactor = 1.0/prefix.factor
        }
        self.unitExponents = [(unit: self, exponent: 1)]
    }
}

public class UnitMultiple : OMUnit {
    
    public let factor: Double
    public let unit: OMUnit
    private let _definedSymbol: String?
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            if _definedSymbol != nil {
                return super.componentsForDisplay
            }
            let prefix = UnitMultiple.findMultipleUsedInSymbol(factor: factor)
            return [StringDisplayComponent(type: .unitPrefix, displayString: prefix),
                    StringDisplayComponent(type: .unitSymbol, displayString: unit.symbol)]
        }
    }
    
    public init(symbol: String? = nil, factor: Double, unit: OMUnit) {
        self.factor = factor
        self.unit = unit
        self._definedSymbol = symbol
        super.init(symbol: symbol, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor*factor)
        self.unitExponents = [(unit: self, exponent: 1)]
    }
}

public class UnitMultiplication : OMUnit {
    
    public let multiplier : OMUnit
    public let multiplicand : OMUnit
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            var display = [StringDisplayComponent]()
            for unitTuple in self.unitExponents {
                display.append(StringDisplayComponent(type: .unitSymbol, displayString: unitTuple.unit.symbol))
                let exponentStr = OMUnit.findMultipleUsedInSymbol(factor: unitTuple.exponent)
                if exponentStr != "1" {
                    display.append(StringDisplayComponent(type: .unitExponent, displayString: exponentStr, baseline: .sup))
                }
                if unitTuple != self.unitExponents.last! {
                    display.append(StringDisplayComponent(type: .unitMultiplier))
                }
            }
            return display
        }
    }
    
    public init(multiplier: OMUnit, multiplicand: OMUnit) {
        self.multiplier = multiplier
        self.multiplicand = multiplicand
        let dimensions = multiplier.dimensions * multiplicand.dimensions
        super.init(symbol: nil, dimensions: dimensions, identifier: "\(multiplier.identifier) * \(multiplicand.identifier)")
        if multiplier.isBaseUnit && multiplicand.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = multiplier.conversionFactor * multiplicand.conversionFactor
            self.baseUnit = multiplier.baseUnit * multiplicand.baseUnit
        }
        self.combineBaseUnitsPerDimension()
        self.unitExponents.removeAll()
        self.uniExponentsAdd(unit: multiplier, exponent: 1)
        self.uniExponentsAdd(unit: multiplicand, exponent: 1)
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [OMUnit: Double]] ()
        for dim in Dimension.allCases {
            let unitExps1 = multiplier.baseUnitsPerDimension[dim]
            let unitExps2 = multiplicand.baseUnitsPerDimension[dim]
            var unitExps = [OMUnit: Double]()
            if unitExps1 != nil {
                for (unit, exponent) in unitExps1! {
                    let existingExponent = unitExps[unit] ?? 0
                    unitExps[unit] = existingExponent + exponent
                }
            }
            if unitExps2 != nil {
                for (unit, exponent) in unitExps2! {
                    let existingExponent = unitExps[unit] ?? 0
                    unitExps[unit] = existingExponent + exponent
                }
            }
            bupds[dim] = unitExps
        }
        self.baseUnitsPerDimension = bupds
    }
}

public class UnitDivision : OMUnit {
    
    public let numerator : OMUnit
    public let denominator : OMUnit
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            var display = [StringDisplayComponent]()
            for unitTuple in self.unitExponents {
                display.append(StringDisplayComponent(type: .unitSymbol, displayString: unitTuple.unit.symbol))
                let exponentStr = OMUnit.findMultipleUsedInSymbol(factor: unitTuple.exponent)
                if exponentStr != "1" {
                    display.append(StringDisplayComponent(type: .unitExponent, displayString: exponentStr, baseline: .sup))
                }
                if unitTuple != self.unitExponents.last! {
                    display.append(StringDisplayComponent(type: .unitMultiplier))
                }
            }
            return display
        }
    }
    
    public init(numerator: OMUnit, denominator: OMUnit) {
        self.numerator = numerator
        self.denominator = denominator
        let dimensions = numerator.dimensions / denominator.dimensions
        super.init(symbol: nil, dimensions: dimensions, identifier: "\(numerator.identifier) / \(denominator.identifier)")
        if numerator.isBaseUnit && denominator.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = numerator.conversionFactor / denominator.conversionFactor
            self.baseUnit = numerator.baseUnit / denominator.baseUnit
        }
        self.combineBaseUnitsPerDimension()
        self.unitExponents.removeAll()
        self.uniExponentsAdd(unit: numerator, exponent: 1)
        self.uniExponentsAdd(unit: denominator, exponent: -1)
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [OMUnit: Double]] ()
        for dim in Dimension.allCases {
            let unitExps1 = numerator.baseUnitsPerDimension[dim]
            let unitExps2 = denominator.baseUnitsPerDimension[dim]
            var unitExps = [OMUnit: Double]()
            if unitExps1 != nil {
                for (unit, exponent) in unitExps1! {
                    let existingExponent = unitExps[unit] ?? 0
                    unitExps[unit] = existingExponent + exponent
                }
            }
            if unitExps2 != nil {
                for (unit, exponent) in unitExps2! {
                    let existingExponent = unitExps[unit] ?? 0
                    unitExps[unit] = existingExponent - exponent
                }
            }
            bupds[dim] = unitExps
        }
        self.baseUnitsPerDimension = bupds
    }
}

public class UnitExponentiation : OMUnit {
    
    public let base : OMUnit
    public let exponent : Double
    
    public override var componentsForDisplay: [StringDisplayComponent] {
        get {
            var display = [StringDisplayComponent]()
            for unitTuple in self.unitExponents {
                display.append(StringDisplayComponent(type: .unitSymbol, displayString: unitTuple.unit.symbol))
                let exponentStr = OMUnit.findMultipleUsedInSymbol(factor: unitTuple.exponent)
                if exponentStr != "1" {
                    display.append(StringDisplayComponent(type: .unitExponent, displayString: exponentStr, baseline: .sup))
                }
                if unitTuple != self.unitExponents.last! {
                    display.append(StringDisplayComponent(type: .unitMultiplier))
                }
            }
            return display
        }
    }
    
    public init(base: OMUnit, exponent: Double) {
        self.base = base
        self.exponent = exponent
        let dimensions = pow(base.dimensions, exponent)
        super.init(symbol: nil, dimensions: dimensions, identifier: "\(base.identifier)^\(exponent)")
        if base.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = pow(base.conversionFactor, Double(exponent))
            self.baseUnit = base.baseUnit
        }
        self.combineBaseUnitsPerDimension()
        self.unitExponents.removeAll()
        self.uniExponentsMultiply(unit: base, exponent: exponent)
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [OMUnit: Double]] ()
        for dim in Dimension.allCases {
            let unitExps1 = base.baseUnitsPerDimension[dim]
            var unitExps = [OMUnit: Double]()
            if unitExps1 != nil {
                for (unit, exponent) in unitExps1! {
                    unitExps[unit] = exponent * self.exponent
                }
            }
            bupds[dim] = unitExps
        }
        self.baseUnitsPerDimension = bupds
    }
}


public class CompoundUnit : OMUnit {
    
    /// An array containing the subunits in which the value is represented.
    ///
    /// The order should be (and is checked to be so) from larger units to smaller units. For instance,
    /// in the case of angles, the order should be degree, arcminute, arcsecond.
    public let partialUnits: [OMUnit]
    
    /// An array containing the units in which the *error* of the value is represented.
    ///
    /// The order should be (and is checked to be so) from larger units to smaller units. For instance,
    /// in the case of angles, the order should be degree, arcminute, arcsecond, milliarcsecond,
    /// microarcsecond.
    public let errorUnits: [OMUnit]
    
    /// A flag determining whether the sign symbol should always be prepended to the string description
    /// of the angle.
    ///
    /// Minus signs will always be displayed but plus signs only when this value is `true`.
    public let displaySign: Bool
    
    
    /// Creates a new compound unit.
    ///
    /// The `partialUnits` array parameter should contain the subunits in order of size. In the case of
    /// angles this would be degree, arcminute, and arcsecond.
    /// ```swift
    /// static let signDegreeArcminuteArcsecond =
    ///     try! CompoundUnit(consistingOf: [degree, arcminute, arcsecond],
    ///                       displaySign: true)
    /// ```
    /// The `displaySign` flag is used to determine whether the positive sign should be displayed when
    /// the value is positive.
    /// - Parameters:
    ///   - partialUnits: An array containing the subunits in order of size.
    ///   - extraErrorUnits: Units that may also be used for errors after the `partialUnits`have
    ///   been tried. This array is appended to the ``partialUnits`` array to create the
    ///   ``errorUnits`` array. The last unit in ``partialUnits`` should be larger than the first
    ///   unit in `extraErrorUnits`.
    ///   - displaySign: A flag determining whether the sign should alway be prepended to the angle.
    /// - Throws: A UnitValidationError is thrown when the `partialUnits` parameter did not
    /// contain any subunits, when the subunits did not have the same dimensions, or when smaller units
    /// were added before larger units (e.g. inches before feet).
    public init(consistingOf partialUnits: [OMUnit], extraErrorUnits: [OMUnit] = [], displaySign: Bool = false) throws {
        self.partialUnits = partialUnits
        self.displaySign = displaySign
        if partialUnits.count < 1 {
            throw UnitValidationError.noPartialUnitsDefined
        }
        try CompoundUnit.testUnitOrder(partialUnits: partialUnits)
        var tempar = [OMUnit]()
        tempar.append(contentsOf: partialUnits)
        tempar.append(contentsOf: extraErrorUnits)
        self.errorUnits = tempar
        try CompoundUnit.testUnitOrder(partialUnits: tempar)
        super.init(symbol: "", baseUnit: partialUnits.first!, conversionFactor: partialUnits.first!.conversionFactor)
    }
    
    // Test whether the units are ordered from large to small.
    private static func testUnitOrder(partialUnits: [OMUnit]) throws {
        let primaryUnit : OMUnit = partialUnits.first!
        let testMeasure = try! Measure(1.0, unit: primaryUnit)
        for (index, partialUnit) in partialUnits.enumerated() {
            if index > 0 {
                if partialUnit.dimensions != primaryUnit.dimensions {
                    throw UnitValidationError.differentDimensionality
                }
                if try testMeasure.convert(to: partialUnit).scalarValue <= 1.0 {
                    throw UnitValidationError.partialUnitInIllegalOrder
                }
            }
        }
    }
}

// MARK: Operators on Units

public func +(lhs: OMUnit, rhs: OMUnit) throws -> OMUnit {
    if lhs.dimensions != rhs.dimensions {
        throw UnitValidationError.differentDimensionality
    }
    return lhs
}

public func -(lhs: OMUnit, rhs: OMUnit) throws -> OMUnit {
    if lhs.dimensions != rhs.dimensions {
        throw UnitValidationError.differentDimensionality
    }
    return lhs
}

public func *(lhs: OMUnit, rhs: OMUnit) -> OMUnit {
    return UnitMultiplication(multiplier: lhs, multiplicand: rhs)
}

public func /(lhs: OMUnit, rhs: OMUnit) -> OMUnit {
    return UnitDivision(numerator: lhs, denominator: rhs)
}

public func pow(base: OMUnit, exponent: Double) -> OMUnit {
    return UnitExponentiation(base: base, exponent: exponent)
}

