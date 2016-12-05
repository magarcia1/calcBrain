//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Miguel Garcia on 11/14/16.
//  Copyright © 2016 GCC. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    private var accumulator: Double = 0.0
    
    private var descriptionAccumulator = "0"
    
    var result: Double{ get{ return accumulator } }
    
    var isPartialResult: Bool = false
    
    var variableValues = [String: Double]()
    
    var description: String{
        get{
            if pending == nil{
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    enum Operation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case Equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : .Constant(M_PI),
        "e" : .Constant(M_E),
        "±" : .UnaryOperation({ -$0}, { "-(" + $0 + ")" }),
        "√" : .UnaryOperation(sqrt, {"²√(" + $0 + ")"}),
        "cos" : .UnaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : .UnaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : .UnaryOperation(tan, { "tan(" + $0 + ")" }),
        "log" : .UnaryOperation(log, { "log(" + $0 + ")" }),
        "x²": .UnaryOperation({$0 * $0}, { "(" + $0 + ")²" }),
        "x⁻¹": .UnaryOperation({1/$0}, { "(" + $0 + ")⁻¹" }),
        "+" : .BinaryOperation({$0 + $1}, { $0 + " + " + $1 }),
        "−" : .BinaryOperation({$0 - $1}, { $0 + " - " + $1 }),
        "×" : .BinaryOperation({$0 * $1}, { $0 + " × " + $1 }),
        "÷" : .BinaryOperation({$0 / $1}, { $0 + " ÷ " + $1 }),
        "=" : .Equals
    ]
    
    struct PendingBinaryOperationInfo {
        var firstOperand: Double
        var binaryFunction: (Double, Double) -> Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    private var pending: PendingBinaryOperationInfo?    //2
    
    // Intended to be Double if it is an operand
    // String if it is an operations
    private var internalProgram = [AnyObject]()
    
    func performOperation(symbol: String){
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction):
                isPartialResult = true
                executePendingbinaryOperation()
                pending = PendingBinaryOperationInfo(firstOperand: accumulator,
                                                     binaryFunction: function,
                                                     descriptionFunction: descriptionFunction,
                                                     descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingbinaryOperation()
            }
        }
    }
    
    func executePendingbinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand,
                                                                  descriptionAccumulator)
            pending = nil
            isPartialResult = false
        }
    }
    
    func setOperand(operand: Double){
        accumulator = operand
        descriptionAccumulator = String(operand)
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variableName: String){
        accumulator = variableValues[variableName] ?? 0
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            clear()
            if let arrayofOps = newValue as? [PropertyList] {
                for op in arrayofOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    }
                    else if let operand = op as? String {
                        if operations[operand] != nil {
                            performOperation(symbol: operand)
                        }
                        else{
                            setOperand(variableName: operand)
                        }
                    }
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        descriptionAccumulator = "0"
        pending = nil
        variableValues.removeValue(forKey: "M")
        internalProgram.removeAll()
    }
}
