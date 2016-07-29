//
//  CalculationDetailTableViewController.swift
//  casacalc
//
//  Created by Charles on 22/7/16.
//  Copyright © 2016 Charles. All rights reserved.
//

import UIKit

class CalculationDetailTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var propertyAddressTextField: UITextField!
    @IBOutlet weak var purchasePriceTextField: UITextField!
    @IBOutlet weak var nationalitySelector: UISegmentedControl!
    @IBOutlet weak var numPropertySelector: UISegmentedControl!
    @IBOutlet weak var basicStampDutyLabel: UILabel!
    @IBOutlet weak var additionalStampDutyLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    /* 
    This value is either passed by 'CalculationTableViewController' in 'prepareForSegue(_:sender:)'
    or constructed as part of adding a new calculation
    */
    var calculation: Calculation?
    
    // for the numeric keypad
    let keyboardToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Formatting
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        // Handle the text field's user input through delegate callbacks.
        propertyAddressTextField.delegate = self
        purchasePriceTextField.delegate = self
        
        purchasePriceTextField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.barStyle = UIBarStyle.Default
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneWithNum))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        keyboardToolbar.sizeToFit()
        
        
        // set up views if editing an existing Calculation.
        if let calculation = calculation {
            navigationItem.title = calculation.propertyAddress
            propertyAddressTextField.text = calculation.propertyAddress
//            purchasePriceTextField.text = String(format: "%.2f", calculation.purchasePrice)
            purchasePriceTextField.text = formatter.stringFromNumber(calculation.purchasePrice)
            nationalitySelector.selectedSegmentIndex = calculation.nationality
            numPropertySelector.selectedSegmentIndex = calculation.numProperty
//            basicStampDutyLabel.text = String(format: "%.2f", calculation.basicStampDuty)
//            additionalStampDutyLabel.text = String(format: "%.2f", calculation.additionalStampDuty)
//            totalPriceLabel.text = String(format: "%.2f", calculation.totalPrice)
            basicStampDutyLabel.text = formatter.stringFromNumber(calculation.basicStampDuty)
            additionalStampDutyLabel.text = formatter.stringFromNumber(calculation.additionalStampDuty)
            totalPriceLabel.text = formatter.stringFromNumber(calculation.totalPrice)
            photoImageView.image = calculation.photo
        }
        
        // Enable the Save button only if the stamp duties have been recomputed.
        checkValidTotalAmount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: numkeypad
    func doneWithNum() {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        let tempDisplay = formatter.numberFromString(purchasePriceTextField.text!)
        purchasePriceTextField.text = formatter.stringFromNumber(tempDisplay!)
        self.view.endEditing(true)
    }
//
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textfield: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
        
        if textfield == purchasePriceTextField && textfield.text != "" {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            
            let tempValue = formatter.numberFromString(textfield.text!)!
            textfield.text = "\(tempValue)"
        }
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
        let text = totalPriceLabel.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
//
//    func textFieldDidEndEditing(textField: UITextField) {
//        checkValidCalculationName()
////        checkValidTotalAmount()
//        navigationItem.title = textField.text
//    }
    
    @IBAction func calculateTaxTotal(sender: AnyObject) {
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        guard let purchasePrice = formatter.numberFromString(purchasePriceTextField.text!) else {
            //show error
            purchasePriceTextField.text = ""
            basicStampDutyLabel.text = ""
            additionalStampDutyLabel.text = ""
            totalPriceLabel.text = ""
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
        
        let roundedPurchasePrice = round(100*Double(purchasePrice))/100
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
        
//        if (!purchasePriceTextField.editing) {
//            purchasePriceTextField.text = String(format: "%.2f", roundedPurchasePrice)
//        }
//        basicStampDutyLabel.text = String(format: "%.2f", roundedBsdAmount)
//        additionalStampDutyLabel.text = String(format: "%.2f", roundedAbsdAmount)
//        totalPriceLabel.text = String(format: "%.2f", totalAmount)
        
        basicStampDutyLabel.text = formatter.stringFromNumber(roundedBsdAmount)
        additionalStampDutyLabel.text = formatter.stringFromNumber(roundedAbsdAmount)
        totalPriceLabel.text = formatter.stringFromNumber(totalAmount)
        
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
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        
        if saveButton === sender {
            let propertyAddress = propertyAddressTextField.text ?? ""
            let purchasePrice = Double(formatter.numberFromString(purchasePriceTextField.text ?? "")!)
            let nationality = nationalitySelector.selectedSegmentIndex
            let numProperty = numPropertySelector.selectedSegmentIndex
            let basicStampDuty = Double(formatter.numberFromString(basicStampDutyLabel.text ?? "")!)
            let additionalStampDuty = Double(formatter.numberFromString(additionalStampDutyLabel.text ?? "")!)
            let totalPrice = Double(formatter.numberFromString(totalPriceLabel.text ?? "")!)
            let photo = photoImageView.image
            
            // Set the calculation to be passed to CalculationTableViewController after the unwind segue.
            calculation = Calculation(propertyAddress: propertyAddress, purchasePrice: purchasePrice, nationality: nationality, numProperty: numProperty, basicStampDuty: basicStampDuty, additionalStampDuty: additionalStampDuty, totalPrice: totalPrice, photo: photo)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // MARK: Actions
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        // Hide the keyboard
        propertyAddressTextField.resignFirstResponder()
        purchasePriceTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media (from camera or library)
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure CalculationDetailTableViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    
    
}
