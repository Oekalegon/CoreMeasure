//
//  Quantity.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

/// The `Quantity` class represents a physical quantity as a subclass of ``Measure``, with
/// added functionality.
open class Quantity : Measure {
    
    /// The symbol used fot the quantity, may be `nil`.
    public let symbol: String?
    
    
    /// Creates a copy of the ``Measure`` in a specific `Quantity`.
    /// - Parameters:
    ///   - symbol: An optional symbol used for the quantity.
    ///   - measure: The measure to be copied in the quanity.
    public init(symbol: String? = nil, measure: Measure) throws {
        self.symbol = symbol
        if measure.usesIntervalOrRatioScale {
            if (measure.scale as? RatioScale) != nil {
                try super.init(measure.scalarValue, error: measure.error, scale: measure.scale as! RatioScale)
            } else {
                try super.init(measure.scalarValue, error: measure.error, scale: measure.scale as! IntervalScale)
            }
        } else if measure.usesScale {
            throw QuantityValidationError.illegalNominalOrOrdinalScale
        } else {
            try super.init(measure.scalarValue, error: measure.error, unit: measure.unit)
        }
    }
    
    /// Creates a new `Quantity` with the specified scalar value and expessed in the specified
    /// unit.
    ///
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity.
    ///   - scalarValue: The scalar value of the `Quantity`.
    ///   - error: The error.   
    ///   - unit: The unit in which the scalar value is expressed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ scalarValue: Double, error: Double? = nil, unit: OMUnit) throws {
        self.symbol = symbol
        try super.init(scalarValue, error:error, unit: unit)
    }
    
    /// Creates a new `Quantity` with the specified scalar value and along the specified interval
    /// scale.
    ///
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity.
    ///   - scalarValue: The scalar value of the `Quantity`.
    ///   - error: The error.
    ///   - scale: The scale in which the scalar value is placed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ scalarValue: Double, error: Double? = nil, scale: IntervalScale) throws {
        self.symbol = symbol
        try super.init(scalarValue, error:error, scale: scale)
    }
    
    /// Creates a new `Quantity` with the specified scalar value and along the specified ratio scale.
    ///
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity.
    ///   - scalarValue: The scalar value of the `Quantity`.
    ///   - error: The error.
    ///   - scale: The scale in which the scalar value is placed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ scalarValue: Double, error: Double? = nil, scale: RatioScale) throws {
        self.symbol = symbol
        try super.init(scalarValue, error:error, scale: scale)
    }
    
    /// Returns a quantity with the inverted scalar value.
    /// - Parameter measure: The quantity to be inverted.
    /// - Returns: The inverted value.
    /// - Throws:ScaleValidationError when the quantity
    /// contains a value in a ratio scale, for which a absolute zero is defined and, therefore, cannot have
    /// a negative value.
    public static prefix func - (measure: Quantity) throws -> Quantity {
        if measure.usesIntervalOrRatioScale {
            if (measure.scale as? IntervalScale) != nil {
                return try Quantity(symbol: measure.symbol, -measure.scalarValue, error: measure.error, scale: measure.scale as! IntervalScale)
            } else {
                throw ScaleValidationError.negativeValuesNotAllowedInRatioScale
            }
        }
        return try Quantity(symbol: measure.symbol, -measure.scalarValue, error: measure.error, unit: measure.unit)
    }
}

/// Defines the methods for subclasses of ``Quantity`` whose values are limited to a specific range,
/// such as specific angles that need to be limited between 0 and π.
public protocol Ranged {
    
    /// The range to which the Quantity is limited as expressed in a tuple containing the minimal and
    /// maximal value.
    var range: (min: Measure, max: Measure) { get }
}
