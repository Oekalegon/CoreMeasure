//
//  Quantity.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

/// The `Quantity` class represents a physical quantity as a subclass of ``Measure``, with
/// added functionality.
public class Quantity : Measure {
    
    /// The symbol used fot the quantity, may be `nil`.
    public let symbol: String?
    
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
    public init(symbol: String? = nil, _ scalarValue: Double, error: Double? = nil, unit: Unit) throws {
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
}

/// Defines the methods for subclasses of ``Quantity`` whose values are limited to a specific range,
/// such as specific angles that need to be limited between 0 and π.
public protocol Ranged {
    
    /// The range to which the Quantity is limited as expressed in a tuple containing the minimal and
    /// maximal value.
    var range: (min: Measure, max: Measure) { get }
}
