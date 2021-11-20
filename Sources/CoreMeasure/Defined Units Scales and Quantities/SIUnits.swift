//
//  SIUnits.swift
//  
//
//  Created by Don Willems on 06/07/2021.
//

import Foundation

public extension OMUnit {
    
    static let one = OMUnit(symbol: "")
    
    // MARK: SI Base units
    static let second = OMUnit(symbol: "s", dimension: .T)
    static let metre = OMUnit(symbol: "m", dimension: .L)
    static let kilogram = PrefixedUnit(prefix: .kilo, unit: .gram, isBaseUnit: true)
    static let kelvin = OMUnit(symbol: "K", dimension: .θ)
    static let mol = OMUnit(symbol: "mol", dimension: .N)
    static let ampere = OMUnit(symbol: "A", dimension: .I)
    static let candela = OMUnit(symbol: "cd", dimension: .J)
    
    // MARK: SI Prefixed units
    static let gram = OMUnit(symbol: "g", dimension: .M)
    
    // MARK: SI Derived Units with Special names
    static let hertz = EquivalentUnit(symbol: "Hz", equivalent: .perSecond)
    static let radian = EquivalentUnit(symbol: "rad", equivalent: .metrePerMetre)
    static let steradian = EquivalentUnit(symbol: "st", equivalent: .squareMetrePerSquareMetre)
    static let newton = EquivalentUnit(symbol: "N", equivalent: .kilogramMetrePerSecondSquared)
    static let pascal = EquivalentUnit(symbol: "Pa", equivalent: .newtonPerSquareMetre)
    static let joule = EquivalentUnit(symbol: "J", equivalent: .newtonMetre)
    static let watt = EquivalentUnit(symbol: "W", equivalent: .joulePerSecond)
    static let coulomb = EquivalentUnit(symbol: "C", equivalent: .ampereSecond)
    static let volt = EquivalentUnit(symbol: "V", equivalent: .wattPerAmpere)
    static let farad = EquivalentUnit(symbol: "F", equivalent: .coulombPerVolt)
    static let ohm = EquivalentUnit(symbol: "Ω", equivalent: .voltPerAmpere)
    static let siemens = EquivalentUnit(symbol: "S", equivalent: .amperePerVolt)
    static let weber = EquivalentUnit(symbol: "Wb", equivalent: .joulePerAmpere)
    static let tesla = EquivalentUnit(symbol: "T", equivalent: .weberPerSquareMetre)
    static let henry = EquivalentUnit(symbol: "H", equivalent: .weberPerAmpere)
    static let degreeCelsius = EquivalentUnit(symbol: "°C", equivalent: .kelvin)
    static let lumen = EquivalentUnit(symbol: "lm", equivalent: .candelaSteradian)
    static let lux = EquivalentUnit(symbol: "lx", equivalent: .lumenPerSquareMetre)
    static let becquerel = EquivalentUnit(symbol: "Bq", equivalent: .perSecond)
    static let gray = EquivalentUnit(symbol: "Gy", equivalent: .joulePerKilogram)
    static let sievert = EquivalentUnit(symbol: "Sv", equivalent: .joulePerKilogram)
    static let katal = EquivalentUnit(symbol: "kat", equivalent: .molPerSecond)
    
    // MARK: SI Derived Units
    static let perSecond = UnitDivision(numerator: .one, denominator: .second)
    static let metrePerMetre = UnitDivision(numerator: .metre, denominator: .metre)
    static let squareMetre = UnitExponentiation(base: .metre, exponent: 2)
    static let cubicMetre = UnitExponentiation(base: .metre, exponent: 3)
    static let squareMetrePerSquareMetre = UnitDivision(numerator: .squareMetre, denominator: .squareMetre)
    static let newtonMetre = UnitMultiplication(multiplier: .newton, multiplicand: .metre)
    static let joulePerSecond = UnitDivision(numerator: .joule, denominator: .second)
    static let ampereSecond = UnitMultiplication(multiplier: .ampere, multiplicand: .second)
    static let wattPerAmpere = UnitDivision(numerator: .watt, denominator: .ampere)
    static let coulombPerVolt = UnitDivision(numerator: .coulomb, denominator: .volt)
    static let voltPerAmpere = UnitDivision(numerator: .volt, denominator: .ampere)
    static let amperePerVolt = UnitDivision(numerator: .ampere, denominator: .volt)
    static let joulePerAmpere = UnitDivision(numerator: .joule, denominator: .ampere)
    static let weberPerSquareMetre = UnitDivision(numerator: .weber, denominator: .squareMetre)
    static let weberPerAmpere = UnitDivision(numerator: .weber, denominator: .ampere)
    static let newtonPerSquareMetre = UnitDivision(numerator: .newton, denominator: .squareMetre)
    static let metrePerSecond = UnitDivision(numerator: .metre, denominator: .second)
    static let metrePerSecondSquared = UnitDivision(numerator: .metre, denominator: UnitExponentiation(base: .second, exponent: 2))
    static let kilogramMetrePerSecondSquared = UnitMultiplication(multiplier: .kilogram, multiplicand: .metrePerSecondSquared)
    static let candelaSteradian = UnitMultiplication(multiplier: .candela, multiplicand: .steradian)
    static let lumenPerSquareMetre = UnitDivision(numerator: .lumen, denominator: .squareMetre)
    static let joulePerKilogram = UnitDivision(numerator: .joule, denominator: .kilogram)
    static let molPerSecond = UnitDivision(numerator: .mol, denominator: .second)
    
    // MARK: Often used prefixed units
    static let kilometre = PrefixedUnit(prefix: .kilo, unit: .metre)
    static let hectometre = PrefixedUnit(prefix: .hecto, unit: .metre)
    static let decimetre = PrefixedUnit(prefix: .deci, unit: .metre)
    static let centimetre = PrefixedUnit(prefix: .centi, unit: .metre)
    static let millimetre = PrefixedUnit(prefix: .milli, unit: .metre)
    static let micrometre = PrefixedUnit(prefix: .micro, unit: .metre)
    static let nanometre = PrefixedUnit(prefix: .nano, unit: .metre)
}
    
public extension Scale {
        
    // MARK: Scales
    static let kelvinScale = RatioScale(with: .kelvin)
    static let celciusScale = IntervalScale(reltativeTo: kelvinScale, offset: try! Measure(-273.15, unit: .degreeCelsius))
    
}
