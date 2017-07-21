//
//  Singletons.swift
//  TipCalc
//
//  Created by Michael Cordover on 07/15/2017.
//  Copyright © 2017 Michael Cordover. All rights reserved.
//

import Foundation


/// User preference data. It's like an ORM, but terrible.
public struct Preferences {
    public struct Names {
        static let tipPercentage = "tipPercentage"
        static let billTotal = "billTotal"
        static let roundToNearest = "roundToNearest"
        static let roundingRule = "roundingRule"
        static let defaultTipPercentage = "defaultTipPercentage"
        static let minimumTipPercentage = "minimumTipPercentage"
        static let maximumTipPercentage = "maximumTipPercentage"
        static let lastUpdated = "lastUpdated"
    }

    public struct Defaults {
        static let tipPercentage: Double = 0.18
        static let billTotal: Double = 0.0
        static let roundToNearest: Double = 0.50
        static let roundingRule: FloatingPointRoundingRule = .up
        static let defaultTipPercentage = 0.18
        static let minimumTipPercentage = 0.10
        static let maximumTipPercentage = 0.25
        static let lastUpdated: Date? = nil
    }

    // It feels like there's probably a better way to do this, though it doesn't seem like this built-in enum has an accessible rawValue
    private static let serializedRoundingRule: [UInt8:FloatingPointRoundingRule] = [
        0: Defaults.roundingRule,
        1: FloatingPointRoundingRule.up,
        2: FloatingPointRoundingRule.toNearestOrAwayFromZero
    ]

    // Oh so many similar getters and setters. It feels like there's a better way to do this too...
    // Also, we don't really want to synchronize() after _every_ set; this is bad for performance and memory wear.
    // The better solution would be to save a memoized version and update that as well as UserDefaults.standard, and then
    // let automatic synchronization happen.
    static var tipPercentage: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.tipPercentage) as? Double ?? Defaults.tipPercentage
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.tipPercentage)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var billTotal: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.billTotal) as? Double ?? Defaults.billTotal
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.billTotal)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var roundToNearest: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.roundToNearest) as? Double ?? Defaults.roundToNearest
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.roundToNearest)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var roundingRule: FloatingPointRoundingRule {
        get {
            // There are a lot of ??s here. We program defensively; if for some reason the data in UserDefaults.standard
            // is not supported, we don't want to crash.
            let raw_rule: UInt8 = UserDefaults.standard.object(forKey: Names.roundingRule) as? UInt8 ?? 0
            return serializedRoundingRule[raw_rule] ?? Defaults.roundingRule
        }
        set(value) {
            let raw_value = serializedRoundingRule.first(where: { (k:UInt8, v:FloatingPointRoundingRule) -> Bool in value == v })?.key
            UserDefaults.standard.set(raw_value ?? 0, forKey: Names.roundingRule)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var defaultTipPercentage: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.defaultTipPercentage) as? Double ?? Defaults.defaultTipPercentage
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.defaultTipPercentage)
            UserDefaults.standard.synchronize()
        }
    }

    static var minimumTipPercentage: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.minimumTipPercentage) as? Double ?? Defaults.minimumTipPercentage
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.minimumTipPercentage)
            UserDefaults.standard.synchronize()
        }
    }

    static var maximumTipPercentage: Double {
        get {
            return UserDefaults.standard.object(forKey: Names.maximumTipPercentage) as? Double ?? Defaults.maximumTipPercentage
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.maximumTipPercentage)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var lastUpdated: Date? {
        get {
            return UserDefaults.standard.object(forKey: Names.lastUpdated) as? Date
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: Names.lastUpdated)
            UserDefaults.standard.synchronize()
        }
    }
}

/// Helper information for numeric text
class NumericTextHelper {
    static var decimalSeparator = "."
    static var numericCharacters = "0123456789"

    static func removeNonNumericCharcters(string: String) -> String {
        return String(string.characters.filter({
            numericCharacters.characters.contains($0) || decimalSeparator.characters.contains($0)
        }))
    }

    // it feels like this method could have a more iOS-y name
    static func noMoreThanOneDecimalPointIn(string: String) -> Bool {
        return string.components(separatedBy: decimalSeparator).count < 3
    }
}

/// Helper for formatting doubles into currency strings
class CurrencyFormatter {
    static var instance: NumberFormatter {
        get {
            // We use this getter to let us run setup on first access
            if _instance == nil {
                _instance = NumberFormatter()
                _instance!.numberStyle = .currency
            }
            return _instance!
        }
    }
    static let textFieldDelegate = NumericTextFieldDelegate(withFormatter: instance)
    private static var _instance: NumberFormatter? = nil
}

/// Helper for formatting doulbes into percentage strings
class PercentageFormatter {
    static var instance: NumberFormatter {
        get {
            // We use this getter to let us run setup on first access
            if _instance == nil {
                _instance = NumberFormatter()
                _instance!.numberStyle = .percent
                _instance!.maximumSignificantDigits = 3
            }
            return _instance!
        }
    }
    static let textFieldDelegate = NumericTextFieldDelegate(withFormatter: instance)
    private static var _instance: NumberFormatter? = nil
}
