//
//  NumericTextFieldDelegate.swift
//  TipCalc
//
//  Created by Michael Cordover on 07/15/2017.
//  Copyright © 2017 Michael Cordover. All rights reserved.
//

import UIKit

class NumericTextFieldDelegate: NSObject, UITextFieldDelegate {

    // MARK: - internal variables
    private var formatter: NumberFormatter
    
    // MARK: - initalizer
    init(withFormatter aFormatter: NumberFormatter) {
        formatter = aFormatter
    }

    // MARK: - delegated methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = NumericTextHelper.removeNonNumericCharcters(string: textField.text ?? "")
        if convertToDouble(string: textField.text!) == 0 {
            textField.text = ""
        }   
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resulting_text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if string.characters.count == 0 {
            return true
        } else if NumericTextHelper.removeNonNumericCharcters(string: string) == string && resulting_text.components(separatedBy: NumericTextHelper.decimalSeparator).count < 3 {
            return true
        } else {
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = formatter.string(from: convertToDouble(string: textField.text!) as NSNumber)
    }

    // MARK: - helper methods
    private func convertToDouble(string: String) -> Double {
        let dbl = Double(string) ?? 0

        // this switch on formatter style feels a little gross, but it's not unreasonable
        switch formatter.numberStyle {
        case .percent:
            return dbl / 100
        default:
            return dbl
        }
    }

}
