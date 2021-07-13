//
//  File.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

/// Errors concerning the validity of units.
public enum UnitValidationError: Error {
    
    /// A ``Unit`` is defined for different dimensions than another ``Unit``, ``Scale``, or
    /// ``Quantity``, and can therefore, not be used.
    case differentDimensionality
    
    /// If a ``Unit`` needs to be related to another unit, e.g. convert a ``Measure`` in one unit to the
    /// other, they need to have the same base unit.
    ///
    /// If the units do not have the same base unit, the conversion factors cannot be calculated, and the
    /// units cannot be converted to one another.
    case noCommonBaseUnit
    
    /// This error is thrown when one tries to convert a ``Unit`` to a ``Scale``, which is not possible
    /// as the unit does not define specific points on a scale, just relative differences.
    case cannotConvertUnitToScale
    
    /// Caused when defining a ``CompoundUnit`` whithout any subunits.
    ///
    /// A ``CompoundUnit`` needs at least one subunit.
    case noPartialUnitsDefined
    
    /// Thrown when defining a ``CompoundUnit`` where the subunits are added to the
    /// ``CompoundUnit`` in an illegal order.
    ///
    /// The order of subunits needs to be such that larger units are added before smaller ones. E.g. the
    /// unit ``degree`` needs to be added before ``arcminute``.
    case partialUnitInIllegalOrder
}

/// Errors concerning the validity of scales.
public enum ScaleValidationError: Error {
    
    /// A ``Scale`` is defined for different dimensions than another ``Scale``, ``Unit``, or
    /// ``Quantity``, and can therefore, not be used.
    case differentDimensionality
    
    /// If a ``Scale`` needs to be related to another unit, e.g. convert a ``Measure`` in one scale to
    /// the other, they need to have the same ``RatioScale``.
    ///
    /// If the scales do not have the same ratio scale, the conversion factors and offsets cannot be
    /// calculated, and the scales cannot be converted to one another.
    case noCommonRatioScale
    
    /// This error is thrown when one tries to convert a ``Scale`` to a ``Unit``, which would result
    /// in a loss of information (i.e. the offset of the scale).
    case cannotConvertScaleToUnit
    
    /// This error is thrown when a non-ratio or -interval scale is attemped to be used when calculating
    /// conversion between scales.
    ///
    /// This happens when the scale is not an interval or ratio scale, e.g a nominal or ordinal scale, which
    /// do not define the proportionality of the values on the scale (ordinal scales) or even the order
    /// (nominal scales).
    case notLinkedToARatioScale
    
    /// Thrown when a scale cannot be used in the arithmetic operation.
    ///
    /// This will happen, for instance, when one tries to add two ``Measure``s in which the right hand
    /// side of the equation is a scale.
    case cannotUseScaleInArithmetic
    
    /// Thrown when one tries to use a nominal or ordinal scale in arithmetic.
    ///
    /// This happens when the scale is not an interval or ratio scale, e.g a nominal or ordinal scale, which
    /// do not define the proportionality of the values on the scale (ordinal scales) or even the order
    /// (nominal scales).
    case cannotUseArithmeticOnNonMeasurementScale
}


/// Errors concerning the validity of quantities.
public enum QuantityValidationError: Error {
    
    /// Thrown when the value of the ``Quantity`` is outside of the range defined for that quantity.
    ///
    /// A value is out of range for a quantity when the quantity has a defined range and the value for
    /// the quantity is outside of that range, for instance when an latitude angle (``Latitude``) has a
    /// value of 120°, where the range of a latitude angle is defined to be [-90°, +90°].
    case outOfRange
}
