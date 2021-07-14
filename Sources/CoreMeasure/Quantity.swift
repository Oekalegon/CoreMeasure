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
    ///     - scalarValue: The scalar value of the `Quantity`
    ///     - unit: The unit in which the scalar value is expressed.
    public override convenience init(_ scalarValue: Double, unit: Unit) throws {
        try self.init(symbol: nil, scalarValue, unit: unit)
    }
    
    /// Creates a new `Quantity` with the specified scalar value and along the specified measurement
    /// scale.
    ///
    /// - Parameters:
    ///     - scalarValue: The scalar value of the `Quantity`
    ///     - scale: The scale in which the scalar value is placed.
    public override convenience init(_ scalarValue: Double, scale: MeasurementScale) throws {
        try self.init(symbol: nil, scalarValue, scale: scale)
    }
    
    /// Creates a new `Quantity` with the specified scalar value and expessed in the specified
    /// unit.
    ///
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity.
    ///     - scalarValue: The scalar value of the `Quantity`.
    ///     - unit: The unit in which the scalar value is expressed.
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ scalarValue: Double, unit: Unit) throws {
        self.symbol = symbol
        try super.init(scalarValue, unit: unit)
    }
    
    /// Creates a new `Quantity` with the specified scalar value and along the specified measurement
    /// scale.
    ///
    /// - Parameters:
    ///   - symbol: The symbol used for the quantity.
    ///     - scalarValue: The scalar value of the `Quantity`.
    ///     - scale: The scale in which the scalar value is placed.     
    /// - Throws: ``UnitValidationError`` or ``ScaleValidationError`` when the
    /// associated unit or scale is incompatible with the quantity or its value.
    public init(symbol: String? = nil, _ scalarValue: Double, scale: MeasurementScale) throws {
        self.symbol = symbol
        try super.init(scalarValue, scale: scale)
    }
}

/// Defines the methods for subclasses of ``Quantity`` whose values are limited to a specific range,
/// such as specific angles that need to be limited between 0 and π.
public protocol Ranged {
    
    /// The range to which the Quantity is limited as expressed in a tuple containing the minimal and
    /// maximal value.
    var range: (min: Measure, max: Measure) { get }
}
