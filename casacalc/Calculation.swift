//
//  Calculation.swift
//  casacalc
//
//  Created by Charles on 22/7/16.
//  Copyright © 2016 Charles. All rights reserved.
//

import UIKit

class Calculation: NSObject, NSCoding {
    // MARK: Properties
    
    var propertyAddress: String
    var purchasePrice: Double
    var nationality: Int
    var numProperty: Int
    var basicStampDuty: Double
    var additionalStampDuty: Double
    var totalPrice: Double
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")
    
    // MARK: Types
    
    struct PropertyKey {
        static let propertyAddressKey = "propertyAddress"
        static let purchasePriceKey = "purchasePrice"
        static let nationalityKey = "nationality"
        static let numPropertyKey = "numProperty"
        static let basicStampDutyKey = "basicStampDuty"
        static let additionalStampDutyKey = "additionalStampDuty"
        static let totalPriceKey = "totalPrice"
    }
    
    // MARK: Initialization
    init?(propertyAddress: String, purchasePrice: Double, nationality: Int, numProperty: Int, basicStampDuty: Double, additionalStampDuty: Double, totalPrice: Double) {
        
        // Initialize stored properties
        self.propertyAddress = propertyAddress
        self.purchasePrice = purchasePrice
        self.nationality = nationality
        self.numProperty = numProperty
        self.basicStampDuty = basicStampDuty
        self.additionalStampDuty = additionalStampDuty
        self.totalPrice = totalPrice
        
        super.init()
        
        // Initialization should fail if there is no address/ purchase price or if the values cannot be computed
        if propertyAddress.isEmpty || purchasePrice <= 0 || nationality < 0 || numProperty < 0 || basicStampDuty <= 0 || additionalStampDuty <= 0 || totalPrice <= 0 {
            return nil
        }
    }
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(propertyAddress, forKey: PropertyKey.propertyAddressKey)
        aCoder.encodeDouble(purchasePrice, forKey: PropertyKey.purchasePriceKey)
        aCoder.encodeInteger(nationality, forKey: PropertyKey.nationalityKey)
        aCoder.encodeInteger(numProperty, forKey: PropertyKey.numPropertyKey)
        aCoder.encodeDouble(basicStampDuty, forKey: PropertyKey.basicStampDutyKey)
        aCoder.encodeDouble(additionalStampDuty, forKey: PropertyKey.additionalStampDutyKey)
        aCoder.encodeDouble(totalPrice, forKey: PropertyKey.totalPriceKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let propertyAddress = aDecoder.decodeObjectForKey(PropertyKey.propertyAddressKey) as! String
        let purchasePrice = aDecoder.decodeDoubleForKey(PropertyKey.purchasePriceKey)
        let nationality = aDecoder.decodeIntegerForKey(PropertyKey.nationalityKey)
        let numProperty = aDecoder.decodeIntegerForKey(PropertyKey.numPropertyKey)
        let basicStampDuty = aDecoder.decodeDoubleForKey(PropertyKey.basicStampDutyKey)
        let additionalStampDuty = aDecoder.decodeDoubleForKey(PropertyKey.additionalStampDutyKey)
        let totalPrice = aDecoder.decodeDoubleForKey(PropertyKey.totalPriceKey)
        
        self.init(propertyAddress: propertyAddress, purchasePrice: purchasePrice, nationality: nationality, numProperty: numProperty, basicStampDuty: basicStampDuty, additionalStampDuty: additionalStampDuty, totalPrice: totalPrice)
    }
}
