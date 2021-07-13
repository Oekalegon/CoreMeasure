//
//  Quantity.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

/// The `Quantity` class represents a physical quantity with its value (a ``Measure``specifying both
/// the numerical value and the unit in which it is expressed).
public class Quantity {
    
    /// The symbol used fot the quantity, may be `nil`.
    public let symbol: String?
    
    /// The  value for the quantity expressed in a specific unit.
    public let value: Measure
    
    /// The dimensions for this quantity. The dimensions should be the same for the unit used.
    public var dimensions: Dimensions {
        get {
            return value.unit.dimensions
        }
    }
    
    /// Creates a new `Quantity` with the specified value and unit.
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity, may be `nil` (default).
    ///   - scalarValue: The numerical value for the quantity.
    ///   - unit: The unit in which the numerical value is expressed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public convenience init(symbol: String? = nil, _ scalarValue: Double, unit: Unit) throws {
        try self.init(symbol: symbol, Measure(scalarValue, unit: unit))
    }
    
    /// Creates a new `Quantity`with the specified measure as its value. The measure contains
    /// the numerical value and the units or scale in which the numerical value is expressed.
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity, may be `nil` (default).
    ///   - value: The value for the quantity as a measure containing the numerical value and the unit
    ///   or scale in which the value is expressed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ value: Measure) throws {
        self.symbol = symbol
        self.value = value
    }
}

/// Defines the methods for subclasses of ``Quantity`` whose values are limited to a specific range,
/// such as specific angles that need to be limited between 0 and π.
public protocol Ranged {
    
    /// The range to which the Quantity is limited as expressed in a tuple containing the minimal and
    /// maximal value.
    var range: (min: Measure, max: Measure) { get }
}
