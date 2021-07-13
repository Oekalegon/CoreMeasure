//
//  Unit.swift
//  
//
//  Created by Don Willems on 05/07/2021.
//

import Foundation

public class Unit : Equatable, Hashable {
    
    public let identifier: String
    public let symbol: String
    public let dimensions: Dimensions
    public fileprivate(set) var isBaseUnit: Bool = false
    private var _baseUnit: Unit?
    public fileprivate(set) var baseUnit : Unit {
        get {
            if _baseUnit == nil {
                return self
            }
            return _baseUnit!
        }
        set(newValue) {
            _baseUnit = newValue
            if _baseUnit == nil {
                self.isBaseUnit = true
            }
        }
    }
    public fileprivate(set) var conversionFactor: Double
    
    internal var baseUnitsPerDimension = [Dimension: [Unit: Int]]()
    
    public convenience init(symbol: String) {
        let dimensions = Dimensions()
        self.init(symbol: symbol, dimensions: dimensions)
        self.isBaseUnit = true
    }
    
    public convenience init(symbol: String, dimension: Dimension) {
        let dimensions = Dimensions([dimension: 1])
        self.init(symbol: symbol, dimensions: dimensions)
        self.isBaseUnit = true
        self.baseUnitsPerDimension[dimension] = [self: 1]
    }
    
    fileprivate init(symbol: String, baseUnit: Unit, conversionFactor: Double = 1.0, identifier: String = UUID().uuidString) {
        self.identifier = identifier
        self._baseUnit = baseUnit.baseUnit
        self.conversionFactor = conversionFactor
        self.symbol = symbol
        self.dimensions = baseUnit.dimensions
        self.baseUnitsPerDimension = baseUnit.baseUnitsPerDimension
        isBaseUnit = false
    }
    
    internal init(symbol: String, dimensions: Dimensions, identifier: String = UUID().uuidString) {
        self.identifier = identifier
        self.conversionFactor = 1.0
        self.symbol = symbol
        self.dimensions = dimensions
        isBaseUnit = true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
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
                unitsInDimLHS = [Unit: Int]()
            }
            if unitsInDimRHS == nil {
                unitsInDimRHS = [Unit: Int]()
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

public class EquivalentUnit : Unit {
    
    public let unit: Unit
    
    public init(symbol: String, equivalent unit: Unit) {
        self.unit = unit
        super.init(symbol: symbol, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor)
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

public class PrefixedUnit : Unit {
    
    public let prefix: Prefix
    public let unit: Unit
    
    public convenience init(symbol: String? = nil, prefix: Prefix, unit: Unit) {
        self.init(symbol: symbol, prefix:prefix, unit:unit, isBaseUnit: false)
    }
    
    internal init(symbol: String? = nil, prefix: Prefix, unit: Unit, isBaseUnit: Bool) {
        self.prefix = prefix
        self.unit = unit
        var sym = symbol
        if sym == nil {
            sym = "\(prefix.symbol)\(unit.symbol)"
        }
        super.init(symbol: sym!, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor*prefix.factor, identifier: "[\(prefix.symbol)]\(unit.identifier)")
        if isBaseUnit {
            self.isBaseUnit = true
            unit.isBaseUnit = false
            unit.baseUnit = self
            unit.conversionFactor = 1.0/prefix.factor
        }
    }
}

public class UnitMultiple : Unit {
    
    public let factor: Double
    public let unit: Unit
    
    public init(symbol: String? = nil, factor: Double, unit: Unit) {
        self.factor = factor
        self.unit = unit
        var unitSymbol = symbol
        if unitSymbol == nil {
            let prefix = UnitMultiple.findMultipleUsedInSymbol(factor: factor)
            unitSymbol = "\(prefix)\(unit.symbol)"
        }
        super.init(symbol: unitSymbol!, baseUnit: unit.baseUnit, conversionFactor: unit.conversionFactor*factor, identifier: "[\(unitSymbol!)]\(unit.identifier)")
    }
    
    // Changes 100.0 to 100 and 100.1233100001 to 100.12331
    private static func findMultipleUsedInSymbol(factor: Double, from exponent: Int = 0) -> String {
        let exp1 : Double = pow(10.0, Double(exponent))
        let diff = fabs(factor * exp1 - Double(Int(factor * exp1 + 0.5)))
        if diff > 0.001 {
            return findMultipleUsedInSymbol(factor: factor, from: exponent + 1)
        }
        if exponent == 0 {
            return "\(Int(factor))"
        }
        return "\(Double(Int(factor * exp1))/exp1)"
    }
}

public class UnitMultiplication : Unit {
    
    public let multiplier : Unit
    public let multiplicand : Unit
    
    public init(multiplier: Unit, multiplicand: Unit) {
        self.multiplier = multiplier
        self.multiplicand = multiplicand
        let dimensions = multiplier.dimensions * multiplicand.dimensions
        let symbol = "\(multiplier.symbol)·\(multiplicand.symbol)"
        super.init(symbol: symbol, dimensions: dimensions, identifier: "\(multiplier.identifier) * \(multiplicand.identifier)")
        if multiplier.isBaseUnit && multiplicand.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = multiplier.conversionFactor * multiplicand.conversionFactor
            self.baseUnit = multiplier.baseUnit * multiplicand.baseUnit
        }
        self.combineBaseUnitsPerDimension()
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [Unit: Int]] ()
        for dim in Dimension.allCases {
            let unitExps1 = multiplier.baseUnitsPerDimension[dim]
            let unitExps2 = multiplicand.baseUnitsPerDimension[dim]
            var unitExps = [Unit: Int]()
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

public class UnitDivision : Unit {
    
    public let numerator : Unit
    public let denominator : Unit
    
    public init(numerator: Unit, denominator: Unit) {
        self.numerator = numerator
        self.denominator = denominator
        let dimensions = numerator.dimensions / denominator.dimensions
        let symbol = "\(numerator.symbol)/\(denominator.symbol)"
        super.init(symbol: symbol, dimensions: dimensions, identifier: "\(numerator.identifier) / \(denominator.identifier)")
        if numerator.isBaseUnit && denominator.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = numerator.conversionFactor / denominator.conversionFactor
            self.baseUnit = numerator.baseUnit / denominator.baseUnit
        }
        self.combineBaseUnitsPerDimension()
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [Unit: Int]] ()
        for dim in Dimension.allCases {
            let unitExps1 = numerator.baseUnitsPerDimension[dim]
            let unitExps2 = denominator.baseUnitsPerDimension[dim]
            var unitExps = [Unit: Int]()
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

public class UnitExponentiation : Unit {
    
    public let base : Unit
    public let exponent : Int
    
    public init(base: Unit, exponent: Int) {
        self.base = base
        self.exponent = exponent
        let dimensions = base.dimensions ^ exponent
        let symbol = "\(base.symbol)^\(exponent)"
        super.init(symbol: symbol, dimensions: dimensions, identifier: "\(base.identifier)^\(exponent)")
        if base.isBaseUnit {
            self.conversionFactor = 1.0
            self.baseUnit = self
        } else {
            self.conversionFactor = pow(base.conversionFactor, Double(exponent))
            self.baseUnit = base.baseUnit
        }
        self.combineBaseUnitsPerDimension()
    }
    
    internal func combineBaseUnitsPerDimension() {
        var bupds = [Dimension: [Unit: Int]] ()
        for dim in Dimension.allCases {
            let unitExps1 = base.baseUnitsPerDimension[dim]
            var unitExps = [Unit: Int]()
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


public class CompoundUnit : Unit {
    
    /// An array containing the subunits in which the unit is represented.
    ///
    /// The order should be (and is checked to be so) from larger units. For instance, in the case of
    /// angles, the order should be degree, arcminute, arcsecond.
    public let partialUnits: [Unit]
    
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
    ///   - displaySign: A flag determining whether the sign should alway be prepended to the angle.
    /// - Throws: A UnitValidationError is thrown when the `partialUnits` parameter did not
    /// contain any subunits, when the subunits did not have the same dimensions, or when smaller units
    /// were added before larger units (e.g. inches before feet).
    public init(consistingOf partialUnits: [Unit], displaySign: Bool = false) throws {
        self.partialUnits = partialUnits
        self.displaySign = displaySign
        if partialUnits.count < 1 {
            throw UnitValidationError.noPartialUnitsDefined
        }
        let primaryUnit : Unit = partialUnits[0]
        let testMeasure = Measure(1.0, unit: primaryUnit)
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
        super.init(symbol: "", baseUnit: primaryUnit.baseUnit, conversionFactor: primaryUnit.conversionFactor)
    }
}

// MARK: Operators on Units

public func +(lhs: Unit, rhs: Unit) throws -> Unit {
    if lhs.dimensions != rhs.dimensions {
        throw UnitValidationError.differentDimensionality
    }
    return lhs
}

public func -(lhs: Unit, rhs: Unit) throws -> Unit {
    if lhs.dimensions != rhs.dimensions {
        throw UnitValidationError.differentDimensionality
    }
    return lhs
}

public func *(lhs: Unit, rhs: Unit) -> Unit {
    return UnitMultiplication(multiplier: lhs, multiplicand: rhs)
}

public func /(lhs: Unit, rhs: Unit) -> Unit {
    return UnitDivision(numerator: lhs, denominator: rhs)
}

public func ^(lhs: Unit, rhs: Int) -> Unit {
    return UnitExponentiation(base: lhs, exponent: rhs)
}

