//
//  ViewController.swift
//  Calculator
//
//  Created by Miguel Garcia on 11/14/16.
//  Copyright © 2016 GCC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping: Bool = false
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var displayDescription: UILabel!
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle! //1
        if (userIsInTheMiddleOfTyping && digit != ".") ||
            (digit == "." && (display.text!.range(of: ".") == nil)){
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            if digit == "." {
                display.text =  "0" + digit
            } else {
                display.text = digit
            }
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue : Double? {
        get {
            //! optional: we have to account for every string passed
            return Double(display.text!)!
        }
        set {
            if let value = newValue {
                display.text = String(value)
                //display Description Needed in here:.....
                displayDescription.text = brain.description + (brain.isPartialResult ? " ..." : " =")
            } else {
                display.text = "0"
                displayDescription.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton){
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let matematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: matematicalSymbol)
        }
        displayValue = brain.result
    }
    
    var saveProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        saveProgram = brain.program
    }
    
    @IBAction func restore() {
        if saveProgram != nil {
            brain.program = saveProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func clearButton() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        displayValue = nil
    }
    
    @IBAction func setValueOfVariable() {
        userIsInTheMiddleOfTyping = false
        brain.variableValues["M"] = displayValue!
        saveProgram = brain.program
        brain.program = saveProgram!
        displayValue = brain.result
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        let variable = sender.currentTitle!
        brain.setOperand(variableName: variable)
        brain.variableValues[variable] = 0.0 //not necesary
        displayValue = brain.result
    }
}


