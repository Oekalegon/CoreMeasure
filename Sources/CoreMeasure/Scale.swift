//
//  Scale.swift
//  
//
//  Created by Don Willems on 07/07/2021.
//

import Foundation

public class Scale: Equatable, Hashable {
    
    public let symbol: String
    public let identifier: String
    
    public init(symbol: String, identifier: String = UUID().uuidString) {
        self.symbol = symbol
        self.identifier = identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: Scale, rhs: Scale) -> Bool {
        if lhs.identifier == rhs.identifier {
            return true
        }
        return false
    }
}

public class MeasurementScale: Scale {
    
    public let unit: Unit
    public var dimensions: Dimensions {
        get {
            return unit.dimensions
        }
    }
    
    public init(symbol: String, with unit: Unit, identifier: String = UUID().uuidString) {
        self.unit = unit
        super.init(symbol: symbol, identifier: identifier)
    }
    
    public static func == (lhs: MeasurementScale, rhs: MeasurementScale) -> Bool {
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

public class IntervalScale: MeasurementScale {
    
    public let ratioScale: RatioScale
    public let offset: Measure
    
    public init(symbol: String? = nil, reltativeTo scale: RatioScale, offset: Measure, identifier: String = UUID().uuidString) {
        self.ratioScale = scale
        self.offset = offset
        super.init(symbol: symbol ?? offset.unit.symbol, with:offset.unit, identifier: identifier)
    }
    
    public static func == (lhs: IntervalScale, rhs: IntervalScale) -> Bool {
        if (lhs as MeasurementScale) == (rhs as MeasurementScale) {
            return true
        }
        if lhs.ratioScale == rhs.ratioScale && lhs.offset == rhs.offset {
            return true
        }
        return false
    }
}

public class RatioScale: MeasurementScale {
    
    public override init(symbol: String? = nil, with unit: Unit, identifier: String = UUID().uuidString) {
        super.init(symbol: symbol ?? unit.symbol, with: unit, identifier: identifier)
    }
}
