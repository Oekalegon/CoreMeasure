//
//  File.swift
//  
//
//  Created by Don Willems on 19/07/2021.
//

import Foundation

protocol StringDisplayComponentsProvider {
    
    var componentsForDisplay : [StringDisplayComponent] {get}
}

public enum StringDisplayComponentType {
    case plus
    case minus
    case value
    case space
    case unitPrefix
    case unitMultiplier
    case unitSymbol
    case unitDivider
    case unitExponent
    case plusMinus
    case errorValue
    case times
    case basePower
    case exponent
    case scaleLabel
}

public enum Baseline {
    case normal
    case sup
    case sub
}

public struct StringDisplayComponent {
    
    public let type: StringDisplayComponentType
    public let displayString: String
    public let baseline: Baseline
    
    public init(type: StringDisplayComponentType, displayString: String? = nil, baseline: Baseline = .normal) {
        self.type = type
        self.baseline = baseline
        switch type {
        case .space:
            self.displayString = " "
        case .plus:
            self.displayString = "+"
        case .minus:
            self.displayString = "-"
        case .unitDivider:
            self.displayString = "/"
        case .plusMinus:
            self.displayString = "±"
        case .times:
            self.displayString = "⨉"
        case .unitMultiplier:
            self.displayString = "·"
        default:
            self.displayString = (displayString != nil) ? displayString! : ""
        }
    }
}
