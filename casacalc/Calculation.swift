//
//  Calculation.swift
//  casacalc
//
//  Created by Charles on 22/7/16.
//  Copyright © 2016 Charles. All rights reserved.
//

import UIKit

class Calculation {
    // Mark: Properties
    
    var address: String
    var purchasePrice: Double
    var basicStampDuty: Double
    var additionalStampDuty: Double
    var totalPrice: Double
    
    // Mark: Initialization
    init?(address: String, purchasePrice: Double, basicStampDuty: Double, additionalStampDuty: Double, totalPrice: Double) {
        
        // Initialize stored properties
        self.address = address
        self.purchasePrice = purchasePrice
        self.basicStampDuty = basicStampDuty
        self.additionalStampDuty = additionalStampDuty
        self.totalPrice = totalPrice
        
        // Initialization should fail if there is no address/ purchase price or if the values cannot be computed
        if address.isEmpty || purchasePrice <= 0 || basicStampDuty <= 0 || additionalStampDuty <= 0 || totalPrice <= 0 {
            return nil
        }
    }
}
