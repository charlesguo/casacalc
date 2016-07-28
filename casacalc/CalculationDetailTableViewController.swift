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
//        let formatter = NSNumberFormatter()
//        formatter.locale = NSLocale(localeIdentifier: "en_SG")
//        formatter.numberStyle = .CurrencyStyle
        
        // Handle the text field's user input through delegate callbacks.
        propertyAddressTextField.delegate = self
        purchasePriceTextField.delegate = self
        
        keyboardToolbar.barStyle = UIBarStyle.Default
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: view, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        keyboardToolbar.sizeToFit()
        purchasePriceTextField.inputAccessoryView = keyboardToolbar
        
        // set up views if editing an existing Calculation.
        if let calculation = calculation {
            navigationItem.title = calculation.propertyAddress
            propertyAddressTextField.text = calculation.propertyAddress
            purchasePriceTextField.text = String(format: "%.2f", calculation.purchasePrice)
//            purchasePriceTextField.text = formatter.stringFromNumber(calculation.purchasePrice)
            nationalitySelector.selectedSegmentIndex = calculation.nationality
            numPropertySelector.selectedSegmentIndex = calculation.numProperty
            basicStampDutyLabel.text = String(format: "%.2f", calculation.basicStampDuty)
            additionalStampDutyLabel.text = String(format: "%.2f", calculation.additionalStampDuty)
            totalPriceLabel.text = String(format: "%.2f", calculation.totalPrice)
//            basicStampDutyLabel.text = formatter.stringFromNumber(calculation.basicStampDuty)
//            additionalStampDutyLabel.text = formatter.stringFromNumber(calculation.additionalStampDuty)
//            totalPriceLabel.text = formatter.stringFromNumber(calculation.totalPrice)
            photoImageView.image = calculation.photo
        }
        
        // Enable the Save button only if the stamp duties have been recomputed.
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
        guard let purchasePrice = Double(purchasePriceTextField.text!) else {
            //show error
            purchasePriceTextField.text = ""
            basicStampDutyLabel.text = ""
            additionalStampDutyLabel.text = ""
            totalPriceLabel.text = ""
            return
        }
        
//        let formatter = NSNumberFormatter()
//        formatter.locale = NSLocale(localeIdentifier: "en_SG")
//        formatter.numberStyle = .CurrencyStyle
        
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
        basicStampDutyLabel.text = String(format: "%.2f", roundedBsdAmount)
        additionalStampDutyLabel.text = String(format: "%.2f", roundedAbsdAmount)
        totalPriceLabel.text = String(format: "%.2f", totalAmount)
        
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
            let basicStampDuty = Double(basicStampDutyLabel.text ?? "")
            let additionalStampDuty = Double(additionalStampDutyLabel.text ?? "")
            let totalPrice = Double(totalPriceLabel.text ?? "")
            let photo = photoImageView.image
            
            // Set the calculation to be passed to CalculationTableViewController after the unwind segue.
            calculation = Calculation(propertyAddress: propertyAddress, purchasePrice: purchasePrice!, nationality: nationality, numProperty: numProperty, basicStampDuty: basicStampDuty!, additionalStampDuty: additionalStampDuty!, totalPrice: totalPrice!, photo: photo)
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
