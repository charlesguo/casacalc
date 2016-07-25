//
//  CalculationDetailTableViewController.swift
//  casacalc
//
//  Created by Charles on 22/7/16.
//  Copyright © 2016 Charles. All rights reserved.
//

import UIKit

class CalculationDetailTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var propertyAddressTextField: UITextField!
    @IBOutlet weak var purchasePriceTextField: UITextField!
    @IBOutlet weak var nationalitySelector: UISegmentedControl!
    @IBOutlet weak var numPropertySelector: UISegmentedControl!
    @IBOutlet weak var basicStampDutyTextField: UITextField!
    @IBOutlet weak var additionalStampDutyTextField: UITextField!
    @IBOutlet weak var totalPriceTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    
    /* 
    This value is either passed by 'CalculationTableViewController' in 'prepareForSegue(_:sender:)'
    or constructed as part of adding a new meal
    */
    var calculation: Calculation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field's user input through delegate callbacks.
        propertyAddressTextField.delegate = self
        purchasePriceTextField.delegate = self
        
        // set up views if editing an existing Calculation.
        if let calculation = calculation {
            propertyAddressTextField.text = calculation.propertyAddress
            purchasePriceTextField.text = String(calculation.purchasePrice)
            nationalitySelector.selectedSegmentIndex = calculation.nationality
            numPropertySelector.selectedSegmentIndex = calculation.numProperty
            basicStampDutyTextField.text = String(calculation.basicStampDuty)
            additionalStampDutyTextField.text = String(calculation.additionalStampDuty)
            totalPriceTextField.text = String(calculation.totalPrice)
        }
        
        // Enable the Save button only if the text field has a valid Calculation Name.
        
//        checkValidCalculationName()
        checkValidTotalAmount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textfield: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
//    func checkValidCalculationName() {
//        // Disable the Save button if the text field is empty.
//        let text = propertyAddressTextField.text ?? ""
//        saveButton.enabled = !text.isEmpty
//    }
//    
//
    func checkValidTotalAmount() {
        // Disable the Save button if totalPriceTextField is empty.
        let text = totalPriceTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
//
//    func textFieldDidEndEditing(textField: UITextField) {
//        checkValidCalculationName()
////        checkValidTotalAmount()
//        navigationItem.title = textField.text
//    }
    
    @IBAction func calculateTaxTotal(sender: AnyObject) {
        guard let purchasePrice = Double(purchasePriceTextField.text!) else {
            //show error
            purchasePriceTextField.text = ""
            basicStampDutyTextField.text = ""
            additionalStampDutyTextField.text = ""
            totalPriceTextField.text = ""
            return
        }
        
        // this is just for the additional buyer's stamp duty
        var taxPercentage = 0.0
        
        switch nationalitySelector.selectedSegmentIndex {
        case 0:
            switch numPropertySelector.selectedSegmentIndex {
            case 0:
                taxPercentage = 0.00
            case 1:
                taxPercentage = 0.07
            case 2:
                taxPercentage = 0.10
            default:
                break
            }
            
        case 1:
            switch numPropertySelector.selectedSegmentIndex {
            case 0:
                taxPercentage = 0.05
            case 1:
                taxPercentage = 0.10
            case 2:
                taxPercentage = 0.15
            default:
                break
            }
            
        case 2:
            switch numPropertySelector.selectedSegmentIndex {
            case 0:
                taxPercentage = 0.15
            case 1:
                taxPercentage = 0.15
            case 2:
                taxPercentage = 0.15
            default:
                break
            }
            
        default:
            break
        }
        
        let roundedPurchasePrice = round(100*purchasePrice)/100
        var bsdAmount = 0.00
        
        if roundedPurchasePrice <= 180000 {
            bsdAmount = 0.01 * roundedPurchasePrice
        } else if roundedPurchasePrice > 180000 && roundedPurchasePrice <= 360000 {
            bsdAmount = 1800 + (0.02 * (roundedPurchasePrice - 180000))
        } else {
            bsdAmount = 5400 + (0.03 * (roundedPurchasePrice - 360000))
        }
        
        let roundedBsdAmount = round(100*bsdAmount)/100
        let absdAmount = roundedPurchasePrice*taxPercentage
        let roundedAbsdAmount = round(100*absdAmount)/100
        let totalAmount = roundedPurchasePrice + roundedBsdAmount + roundedAbsdAmount
        
        if (!purchasePriceTextField.editing) {
            purchasePriceTextField.text = String(format: "%.2f", roundedPurchasePrice)
        }
        basicStampDutyTextField.text = String(format: "%.2f", roundedBsdAmount)
        additionalStampDutyTextField.text = String(format: "%.2f", roundedAbsdAmount)
        totalPriceTextField.text = String(format: "%.2f", totalAmount)
        
        let text1 = propertyAddressTextField.text ?? ""
        let text2 = purchasePriceTextField.text ?? ""
        
        saveButton.enabled = true && !(text1.isEmpty) && !(text2.isEmpty)
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddCalculationMode = presentingViewController is UINavigationController
        
        if isPresentingInAddCalculationMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if saveButton === sender {
            let propertyAddress = propertyAddressTextField.text ?? ""
            let purchasePrice = Double(purchasePriceTextField.text ?? "")
            let nationality = nationalitySelector.selectedSegmentIndex
            let numProperty = numPropertySelector.selectedSegmentIndex
            let basicStampDuty = Double(basicStampDutyTextField.text ?? "")
            let additionalStampDuty = Double(additionalStampDutyTextField.text ?? "")
            let totalPrice = Double(totalPriceTextField.text ?? "")
            
            // Set the calculation to be passed to CalculationTableViewController after the unwind segue.
            calculation = Calculation(propertyAddress: propertyAddress, purchasePrice: purchasePrice!, nationality: nationality, numProperty: numProperty, basicStampDuty: basicStampDuty!, additionalStampDuty: additionalStampDuty!, totalPrice: totalPrice!)
        }
    }
    
    // MARK: Actions (only for image)
}
