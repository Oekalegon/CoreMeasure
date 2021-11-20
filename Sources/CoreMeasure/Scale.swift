//
//  Scale.swift
//  
//
//  Created by Don Willems on 07/07/2021.
//

import Foundation

/// A scale defines a way to measure a variable along a predefined set of values.
///
///This class is meant to be subclassed and instances cannot be created.
public class Scale: Equatable, Hashable {
    
    /// The symbol used for this scale.
    public let symbol: String?
    
    /// The unique identifier for the scale.
    public let identifier: String
    
    /// Creates a new scale with the specified symbik and identifier.
    ///
    /// This constructor is only accessible to other classes defined in this file.
    fileprivate init(symbol: String?, identifier: String = UUID().uuidString) {
        self.symbol = symbol
        self.identifier = identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    /// Two scales equal when their identifiers are equal.
    /// - Parameters:
    ///     - lhs: The left hand side scale of the equality equation.
    ///     - rhs: The right hand side scale of the equality equation.
    /// - Returns: ´true´ when the identifiers of the scales are equal.
    public static func == (lhs: Scale, rhs: Scale) -> Bool {
        if lhs.identifier == rhs.identifier {
            return true
        }
        return false
    }
}

/// Implements a *nominal* scale.
///
/// A nominal scale only defines specific values that a measure can have. There is no ordering in a
/// nominal scale. An example would be gender.
public class NominalScale: Scale {
    
    /// The labels which are allowed for the variable in this scale.
    public let labels : [String]
    
    /// Creates a new ``NominalScale`` with the specified symbol and set of labell that are allowed
    /// for values within this scale.
    /// - Parameters:
    ///   - symbol: The symbol for this scale, may be nil.
    ///   - labels: The allowed labels that a value can have.
    ///   - identifier: The identifier of the scale.
    public init(symbol: String?, labels: [String], identifier: String = UUID().uuidString) {
        self.labels = labels
        super.init(symbol: symbol, identifier: identifier)
    }
}


/// Implements an *ordinal* scale.
///
/// An ordinal scale not only defines specific values that a measure can have but also the ordering between
/// the possible values. It does, however, not establish the degree of variation. An example of an ordinal scale
/// could be something like: 'extra small', 'small', 'medium', 'large' , and 'extra large', where 'small' is smaller
/// than 'medium' but there is no definition on how much smaller these 'small' is.
public class OrdinalScale: Scale {
    
    /// The ordered labels which are allowed for the variable in this scale.
    ///
    /// The labels are ordered from small to large, i.e. a measure with the first label as its value will be
    /// smaller than a measure with the second label as its value.
    public let labels : [String]

    /// Creates a new ``OrdinalScale`` with the specified symbol and ordered set of labell that are
    /// allowed for values within this scale.
    /// - Parameters:
    ///   - symbol: The symbol for this scale, may be nil.
    ///   - labels: The allowed labels that a value can have. The labels should be ordered from small
    ///   to large, i.e. a measure with the first label as its value will be smaller than a measure with the
    ///   second label as its value.
    ///   - identifier: The identifier of the scale.
    public init(symbol: String?, labels: [String], identifier: String = UUID().uuidString) {
        self.labels = labels
        super.init(symbol: symbol, identifier: identifier)
    }
}

/// This class defines an *interval* scale.
///
/// An interval scale is scale in which the (size of the) interval between the different values in the scale is
/// defined. Unlike ``NominalScale``s and ``OrdinalScale``s, the value is defined as a numerical
/// value instead of a label.
/// What is not defined, however, is the *absolute* zero point of the scale. For instance, the Celsius or
/// Fahrenheit scales, do have a zero point defined (the freezing point of water for the Celsius scale), but it is
/// not an *absolute* zero. It is allowed to have negative values.
///
/// If an *absolute* zero is defined, you should use a ``RatioScale`` instead of an ``IntervalScale``.
/// Interval scales are often defined in relation to a ``RatioScale``, which allows conversion between
/// dfferent interval scales. Both the Celsius and Fahrenheit scales are defined with relation to the Kelvin
/// scale, which is a ``RatioScale`` as it defines its zero point as the absolute zero for temperature.
public class IntervalScale: Scale {
    
    /// The ``RatioScale`` in relation to which the interval scale is defined.
    ///
    /// The ``ratioScale`` may also be `nil`, but no conversion to other scales will be possible then.
    public let ratioScale: RatioScale?
    
    /// The offset with the ratio scale in relation to which this interval scale is defined.
    ///
    /// The ``offset`` may also be `nil`, but no conversion to other scales will be possible then.
    public let offset: Measure?
    
    /// The unit used for this interval scale.
    ///
    /// If the ``offset`` to a ratio scale is defined, the unit of the scale will be the same as the unit for
    /// the ``offset``.
    public let unit: OMUnit
    
    /// The dimensions in which this interval scale is defined.
    public var dimensions: Dimensions {
        get {
            return unit.dimensions
        }
    }
    
    /// Creates a new interval scale in relation to a specific ratio scale.
    ///
    /// The relation to the relation scale is defined by the ``offset``. The units used for this scale are the
    /// same as those defined for the offset. For instance the Celsius scale is defined in relation to the
    /// Kelvin scale as its ratio scale. The offset is equal to -273.15 °C. It is defined in code as follows:
    /// ```swift
    /// static let celciusScale = IntervalScale(reltativeTo: kelvinScale,
    ///                                         offset: try! Measure(-273.15, unit: .degreeCelsius))
    /// ``
    /// - Parameters:
    ///   - symbol: The symbol used for the scale. This argument may be ´nil´
    ///   but will then be set to the same symbol as used for the ´offset``
    ///   measure.
    ///   - scale: The ratio scale in relation to which the interval scale is
    ///   defined.
    ///   - offset: The offset between the origin of the interval scale and the
    ///   absolute zero value of the ratio scale.
    ///   - identifier: The identifier of the scale.
    public init(symbol: String? = nil, reltativeTo scale: RatioScale, offset: Measure, identifier: String = UUID().uuidString) {
        self.ratioScale = scale
        self.offset = offset
        self.unit = offset.unit
        super.init(symbol: symbol ?? offset.unit.symbol, identifier: identifier)
    }
    
    /// Creates a new interval scale without specifying a ratio scale.
    ///
    /// Using this constructor interval scales can be defined without a relation to a ratio scale. This means,
    /// however, that values in this scale cannot be converted to another scale.
    ///
    /// An example where this could be used would be the elevation of a location on Earth. This would
    /// be defined as follow:
    /// ```swift
    /// static let elevationScale = IntervalScale(symbol: "h", unit: .metre)
    /// ```
    /// Values in this scale cannot be converted to another scale as no zero point is defined. One might
    /// think of another scale, such as distance to the centre of the Earth. You might then redefine the
    /// elevation scale with relation to that ratio scale. The distance to the centre of the Earth would be
    /// a ratio scale as it defines a zero point (the centre of the Earth) and negative values would be
    /// meaningless.
    /// - Parameters:
    ///   - symbol: The symbol to be used for the scale, may be `nil`.
    ///   - unit: The unit used in the scale.
    ///   - identifier: The identifier of the scale.
    public init(symbol: String? = nil, unit: OMUnit, identifier: String = UUID().uuidString) {
        self.ratioScale = nil
        self.offset = nil
        self.unit = unit
        super.init(symbol: symbol, identifier: identifier)
    }
    
    public static func == (lhs: IntervalScale, rhs: IntervalScale) -> Bool {
        if (lhs as Scale) == (rhs as Scale) {
            return true
        }
        if lhs.dimensions != rhs.dimensions {
            return false
        }
        if lhs.ratioScale == rhs.ratioScale && lhs.offset == rhs.offset {
            if lhs.unit == rhs.unit {
                return true
            }
        }
        return false
    }
}


/// This class defines a *ratio* scale.
///
/// An ratio scale is scale in which the (size of the) interval between the different values in the scale is
/// defined. Unlike ``NominalScale``s and ``OrdinalScale``s, the value is defined as a numerical
/// value instead of a label.
///
/// Moreover, a ratio scale also defines *absolute* zero. Negative values in a ratio scale should be
/// meaningless and not allowed.
///
/// An example wouild be the kelvin scale where an absolute zero temperature is defined. Temperatures
/// below absolute zero are not possible. 
public class RatioScale: Scale {
    
    /// The unit used in this ratio scale
    public let unit: OMUnit
    
    /// The dimension of the scale
    ///
    /// This will be the same as the dimensions of the ``unit``.
    public var dimensions: Dimensions {
        get {
            return unit.dimensions
        }
    }
    
    /// Creates a new ratio scale.
    ///
    /// A ratio scale defines an absolute zero and negative values in ratio scale are meaningless and not
    /// allowed.
    ///
    /// An example wouild be the kelvin scale where an absolute zero temperature is defined. Temperatures
    /// below absolute zero are not possible.
    /// - Parameters:
    ///   - symbol: The symbol to be used for the scale, may be `nil`.
    ///   - unit: The unit used in the scale.
    ///   - identifier: The identifier of the scale.
    public init(symbol: String? = nil, with unit: OMUnit, identifier: String = UUID().uuidString) {
        self.unit = unit
        super.init(symbol: symbol ?? unit.symbol, identifier: identifier)
    }
    
    public static func == (lhs: RatioScale, rhs: RatioScale) -> Bool {
        if (lhs as Scale) == (rhs as Scale) {
            return true
        }
        if lhs.dimensions != rhs.dimensions {
            return false
        }
        if lhs.unit == rhs.unit {
            return true
        }
        return false
    }
}
