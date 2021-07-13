//
//  Dimensions.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

/// An enumeration of the seven principle dimensions in the SI system of units in which all units can be
/// defined.
///
/// Each ``Unit``, ``State``, or ``Quantity`` is defined as a combination of exponentiations of
/// these seven dimensions. For instance, the unit of acceleration (m/s^2) is defined with the dimensions
/// of length with exponent value 1 and time with exponent value -2. Usually this is represented as
/// (T=-2, L=1).
public enum Dimension : String, CaseIterable {
    
    /// The time dimension.
    case T
    
    /// The length dimension.
    case L // Length
    
    /// The mass dimension.
    case M // Mass
    
    /// The electric current dimension.
    case I // Electric Current
    
    /// The thermodynamic time dimension
    case θ // Thermodynamic Temperature
    
    /// The amount of substance dimension.
    case N // Amount of substance
    
    /// The luminous intensity dimension.
    case J // Lumninous Intensity
}

/// Represents a set of (max. seven) dimensions as defined in the ``Dimension`` enumeration.
///
/// Each ``Unit``, ``State``, or ``Quantity`` is defined as a combination of exponentiations of
/// the seven dimensions. For instance, the unit of acceleration (m/s^2) is defined with the dimensions
/// of length with exponent value 1 and time with exponent value -2. Usually this is represented as
/// (T=-2, L=1).
public struct Dimensions: Equatable, CustomStringConvertible {
    
    private let dimensions: [Dimension: Int]
    
    /// The exponentiation for the dimension as defined in the index of the subscript.
    ///
    /// For instance, in te case of the unit of acceleration (m/s^2):
    /// ```swift
    /// print("\(Unit.metrePerSecondSquared.dimensions[.L])")
    /// // 1
    /// print("\(Unit.metrePerSecondSquared.dimensions[.T])")
    /// // -2
    /// ```
    public subscript(index: Dimension) -> Int {
        get {
            let dim = dimensions[index]
            if dim == nil {
                return 0
            }
            return dim!
        }
    }
    
    /// Creates a new ``Dimensions`` object with the specified dimensions and corresponding
    /// exponentiation values in tuples.
    ///
    /// For instance, in te case of the unit of acceleration (m/s^2):
    /// ```swift
    /// _ = Dimensions((dimension: .L, exponent: 1), (dimension: .T, exponent: -2))
    /// ```
    /// - Parameter dimensions: The dimensions specified in a set of tuples of the form
    ///  `(dimension: Dimension, exponent: Int)`.
    public init(_ dimensions: (dimension: Dimension, exponent: Int)...) {
        var dims = [Dimension: Int]()
        for dim in dimensions {
            dims[dim.dimension] = dim.exponent
        }
        self.dimensions = dims
    }
    
    /// Creates a new ``Dimensions`` object with the specified dimensions and corresponding
    /// exponentiation values in a dictionary..
    ///
    /// For instance, in te case of the unit of acceleration (m/s^2):
    /// ```swift
    /// _ = Dimensions([.L: 11, .T: -2))
    /// ```
    /// - Parameter dimensions: A dictionary with the ``Dimension`` as the key and the
    /// exponent value as the value.
    public init(_ dimensions: [Dimension: Int]) {
        self.dimensions = dimensions
    }
    
    /// Tests whether the specified dimensions are equal.
    ///
    /// The dimensions are equal when all the exponents for each dimension have the same value.
    /// If the dimensions are equal, units with those dimensions can be related to each other.
    /// - Parameters:
    ///     - lhs: The dimension on the left hand side of the equation.
    ///     - lhs: The dimension on the right hand side of the equation.
    /// - Returns: `true` when the dimensions are equal, `false` otherwise.
    public static func == (lhs: Dimensions, rhs: Dimensions) -> Bool {
        for dim in Dimension.allCases {
            if lhs[dim] != rhs[dim] {
                return false
            }
        }
        return true
    }
    
    
    /// A textual description of the set of dimensions in the form such as (T=-2, L=1).
    public var description: String {
        get {
            var str = ""
            if self[.I] != 0 {
                str = "T=\(self[.I])"
            }
            if self[.L] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "L=\(self[.L])"
            }
            if self[.M] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "M=\(self[.M])"
            }
            if self[.I] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "I=\(self[.I])"
            }
            if self[.θ] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "θ=\(self[.θ])"
            }
            if self[.N] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "N=\(self[.N])"
            }
            if self[.J] != 0 {
                if str.count > 0 {
                    str = "\(str), "
                }
                str = "J=\(self[.J])"
            }
            return "(\(str))"
        }
    }
}

// MARK:- Operators on Dimensions

public func *(lhs: Dimensions, rhs: Dimensions) -> Dimensions {
    var dims = [Dimension: Int]()
    for dim in Dimension.allCases {
        dims[dim] = lhs[dim] + rhs[dim]
    }
    return Dimensions(dims)
}

public func /(lhs: Dimensions, rhs: Dimensions) -> Dimensions {
    var dims = [Dimension: Int]()
    for dim in Dimension.allCases {
        dims[dim] = lhs[dim] - rhs[dim]
    }
    return Dimensions(dims)
}

public func ^(lhs: Dimensions, rhs: Int) -> Dimensions {
    var dims = [Dimension: Int]()
    for dim in Dimension.allCases {
        dims[dim] = lhs[dim] * rhs
    }
    return Dimensions(dims)
}
