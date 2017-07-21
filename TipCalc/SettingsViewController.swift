//
//  SettingsViewController.swift
//  TipCalc
//
//  Created by Michael Cordover on 07/15/2017.
//  Copyright © 2017 Michael Cordover. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    // MARK: - outlets
    @IBOutlet weak var defaultTipPercentageField: UITextField!
    @IBOutlet weak var minimumTipPercentageField: UITextField!
    @IBOutlet weak var maximumTipPercentageField: UITextField!
    @IBOutlet weak var roundToNearestField: UITextField!
    @IBOutlet weak var roundUpSwitch: UISwitch!
    @IBOutlet weak var discardChangesCell: UITableViewCell!

    // MARK: - local data
    private var isDirty: Bool = false {
        didSet {
            discardChangesCell.isHidden = !isDirty
        }
    }

    private var defaultTipPercentage: Double = 0.18
    private var minimumTipPercentage: Double = 0.10
    private var maximumTipPercentage: Double = 0.25
    private var roundToNearest: Double = 0.50
    private var roundingRule: FloatingPointRoundingRule = .up

    // MARK: - event handlers
    @IBAction func restoreTextColor(_ sender: UITextField) {
        sender.textColor = nil
    }
    
    @IBAction func discardChangesTapped(_ sender: UIButton) {
        initializeData()
        makeFieldsReflectValues()
    }

    @IBAction func resetToDefaultsTapped(_ sender: UIButton) {
        resetTextColors()
        defaultTipPercentage = Preferences.Defaults.defaultTipPercentage
        minimumTipPercentage = Preferences.Defaults.minimumTipPercentage
        maximumTipPercentage = Preferences.Defaults.maximumTipPercentage
        roundToNearest = Preferences.Defaults.roundToNearest
        
        roundingRule = Preferences.Defaults.roundingRule

        makeFieldsReflectValues()
        isDirty = true
    }

    @IBAction func roundUpSwitchToggled(_ sender: UISwitch) {
        roundingRule = sender.isOn ? FloatingPointRoundingRule.up: FloatingPointRoundingRule.toNearestOrAwayFromZero
        isDirty = true
    }

    @IBAction func validatePercentages(_ sender: UITextField) {
        let doubleFromText = Double(sender.text!)
        switch sender {
        case roundToNearestField:
            if doubleFromText != nil {
                roundToNearest = doubleFromText!
            }
            break;
        case defaultTipPercentageField:
            let intended = (doubleFromText != nil ? doubleFromText! / 100 : defaultTipPercentage)
            if (intended < minimumTipPercentage) {
                defaultTipPercentage = minimumTipPercentage
                sender.text = String(minimumTipPercentage * 100)
                animateInvalid(view: sender)
            } else if (intended > maximumTipPercentage) {
                defaultTipPercentage = maximumTipPercentage
                sender.text = String(maximumTipPercentage * 100)
                animateInvalid(view: sender)
            } else {
                defaultTipPercentage = intended
            }
            break;
        case minimumTipPercentageField:
            let intended = (doubleFromText != nil ? doubleFromText! / 100 : minimumTipPercentage)
            if (intended > maximumTipPercentage) {
                minimumTipPercentage = maximumTipPercentage
                sender.text = String(minimumTipPercentage * 100)
                animateInvalid(view: sender)
            } else {
                minimumTipPercentage = intended
            }
            if (minimumTipPercentage > defaultTipPercentage) {
                defaultTipPercentage = minimumTipPercentage
                defaultTipPercentageField.text = PercentageFormatter.instance.string(from:defaultTipPercentage as NSNumber)
                animateInvalid(view: defaultTipPercentageField)
            }
            break;
        case maximumTipPercentageField:
            let intended = (doubleFromText != nil ? doubleFromText! / 100 : maximumTipPercentage)
            if (intended < minimumTipPercentage) {
                maximumTipPercentage = minimumTipPercentage
                sender.text = String(maximumTipPercentage * 100)
                animateInvalid(view: sender)
            } else {
                maximumTipPercentage = intended
            }
            if (maximumTipPercentage < defaultTipPercentage) {
                defaultTipPercentage = maximumTipPercentage
                defaultTipPercentageField.text = PercentageFormatter.instance.string(from:defaultTipPercentage as NSNumber)
                animateInvalid(view: defaultTipPercentageField)
            }
            break;
        default:
            return
        }
        isDirty = true
    }

    @IBAction func onTapOutside(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultTipPercentageField.delegate = PercentageFormatter.textFieldDelegate
        minimumTipPercentageField.delegate = PercentageFormatter.textFieldDelegate
        maximumTipPercentageField.delegate = PercentageFormatter.textFieldDelegate
        roundToNearestField.delegate = CurrencyFormatter.textFieldDelegate

        discardChangesCell.isHidden = true
        
        initializeData()
        makeFieldsReflectValues()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard isDirty else {
            return
        }
        saveData()
    }
    
    // MARK: - display updates
    private func makeFieldsReflectValues() {
        resetTextColors()

        defaultTipPercentageField.text = PercentageFormatter.instance.string(from: defaultTipPercentage as NSNumber)
        minimumTipPercentageField.text = PercentageFormatter.instance.string(from: minimumTipPercentage as NSNumber)
        maximumTipPercentageField.text = PercentageFormatter.instance.string(from: maximumTipPercentage as NSNumber)
        roundToNearestField.text = CurrencyFormatter.instance.string(from: roundToNearest as NSNumber)
        roundUpSwitch.setOn(roundingRule == FloatingPointRoundingRule.up, animated: false)
    }

    private func resetTextColors() {
        defaultTipPercentageField.textColor = nil
        minimumTipPercentageField.textColor = nil
        maximumTipPercentageField.textColor = nil
        roundToNearestField.textColor = nil
    
    }
    
    private func animateInvalid(view: UITextField) {
        let shakeAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        shakeAnimation.repeatCount = 4
        shakeAnimation.duration = 0.07
        shakeAnimation.autoreverses = true
        shakeAnimation.byValue = -5
        
        view.textColor = .red
        view.layer.add(shakeAnimation, forKey: "position")
    }

    
    // MARK: - data handling
    private func initializeData() {
        defaultTipPercentage = Preferences.defaultTipPercentage
        minimumTipPercentage = Preferences.minimumTipPercentage
        maximumTipPercentage = Preferences.maximumTipPercentage
        roundToNearest = Preferences.roundToNearest
        roundingRule = Preferences.roundingRule
        isDirty = false
    }

    private func saveData() {
        Preferences.defaultTipPercentage = defaultTipPercentage
        Preferences.minimumTipPercentage = minimumTipPercentage
        Preferences.maximumTipPercentage = maximumTipPercentage
        Preferences.roundToNearest = roundToNearest
        Preferences.roundingRule = roundingRule
        isDirty = false
    }
}
