//
//  File.swift
//  
//
//  Created by Don Willems on 11/07/2021.
//

import Foundation

public extension Unit {
    
    // MARK: Units
    static let degreesFahrenheit = UnitMultiple(symbol: "°F", factor: 5.0/9.0, unit: .kelvin)
    static let degreesRéaumur = UnitMultiple(symbol: "°Ré", factor: 5.0/4.0, unit: .kelvin)
}

public extension Scale {
    
    // MARK: Scales
    
    static let fahrenheitScale = IntervalScale(reltativeTo: Scale.kelvinScale, offset: try! Measure(-459.67, unit: .degreesFahrenheit))
    static let réaumurScale = IntervalScale(reltativeTo: Scale.kelvinScale, offset: try! Measure(-218.52, unit: .degreesRéaumur))
}
