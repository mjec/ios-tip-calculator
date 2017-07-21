//
//  ViewController.swift
//  TipCalc
//
//  Created by Michael Cordover on 07/14/2017.
//  Copyright © 2017 Michael Cordover. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - outlets
    @IBOutlet weak var billTotalField: UITextField!
    @IBOutlet weak var tipPercentageSlider: UISlider!
    @IBOutlet weak var tipPercentageLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!

    // MARK: - local data
    private var tipPercentage: Double = 0
    private var billTotal: Double = 0
    private var roundToNearest: Double = 0
    private var roundingRule: FloatingPointRoundingRule = .up
    
    // MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        billTotalField.delegate = CurrencyFormatter.textFieldDelegate
        // we have to call updateData() before updateTotalsDisplay(), even though it's also called in viewWillAppear
        updateData()
        updateTotalsDisplay()

        billTotal = Preferences.Defaults.billTotal
        tipPercentage = Preferences.defaultTipPercentage

        if (Preferences.lastUpdated != nil) {
            let tenMinutesAgo = Date().addingTimeInterval(TimeInterval(-600))
            if tenMinutesAgo < Preferences.lastUpdated! {
                billTotal = Preferences.billTotal
                tipPercentage = Preferences.tipPercentage
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        updateLocale()
    }

    override func viewDidAppear(_ animated: Bool) {
        billTotalField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Preferences.billTotal = billTotal
        Preferences.tipPercentage = tipPercentage
    }
    
    // MARK: - data handling
    private func updateData() {
        roundToNearest = Preferences.roundToNearest
        roundingRule = Preferences.roundingRule
        tipPercentageSlider.minimumValue = Float(Preferences.minimumTipPercentage * 100)
        tipPercentageSlider.maximumValue = Float(Preferences.maximumTipPercentage * 100)
        updateTipPercentageDisplay()
    }
    
    private func updateLocale() {
        CurrencyFormatter.instance.locale = Locale.current
        NumericTextHelper.decimalSeparator = Locale.current.decimalSeparator ?? ""
        // TODO: consider updating NumericTextHelper.numericCharacters
        billTotalField.placeholder = Locale.current.currencySymbol
    }
    
    // MARK: - event handling
    @IBAction func onTapOutside(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onLabelDoubleTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended && roundToNearest != 0 else {
            return
        }

        let oldTipAmount = tipPercentage * billTotal
        var roundedTipAmount: Double
        
        switch sender.view! {
        case tipAmountLabel:
            roundedTipAmount = (oldTipAmount / roundToNearest).rounded(roundingRule) * roundToNearest
            // Make sure the tip doesn't go below 0
            if roundedTipAmount <= 0 {
                roundedTipAmount = (oldTipAmount / roundToNearest).rounded(.up) * roundToNearest
            }
            break
        case totalAmountLabel:
            let billWithTip = oldTipAmount + billTotal
            var roundedBillAmount = (billWithTip / roundToNearest).rounded(roundingRule) * roundToNearest
            // Make sure the tip doesn't go below 0
            if roundedBillAmount <= billTotal {
                roundedBillAmount = (billWithTip / roundToNearest).rounded(.up) * roundToNearest
            }
            roundedTipAmount = roundedBillAmount - billTotal
            break
        default:
            return
        }
        tipPercentage = roundedTipAmount / billTotal
        updateTipPercentageDisplay()
        updateTotalsDisplay()
    }

    @IBAction func sliderMoved(_ sender: Any) {
        tipPercentage = Double(tipPercentageSlider.value.rounded() / 100)
        updateTipPercentageDisplay()
        updateTotalsDisplay()
    }

    @IBAction func billAmountEdited(_ sender: Any) {
        billTotal = Double(billTotalField.text!) ?? 0
        updateTotalsDisplay()
    }

    // MARK: - display updates
    
    private func updateTotalsDisplay() {
        tipAmountLabel.text = CurrencyFormatter.instance.string(from: tipPercentage * billTotal as NSNumber)
        totalAmountLabel.text = CurrencyFormatter.instance.string(from: (1 + tipPercentage) * billTotal as NSNumber)
    }
 
    private func updateTipPercentageDisplay() {
        tipPercentageLabel.text = PercentageFormatter.instance.string(from: tipPercentage as NSNumber)
        
        let newSliderValue = Float(tipPercentage * 100)
        if newSliderValue < tipPercentageSlider.minimumValue {
            tipPercentageSlider.value = tipPercentageSlider.minimumValue
        } else if newSliderValue > tipPercentageSlider.maximumValue {
            tipPercentageSlider.value = tipPercentageSlider.maximumValue
        } else {
            tipPercentageSlider.value = newSliderValue
        }
    }
}
