//
//  CalculationTableViewController.swift
//  casacalc
//
//  Created by Charles on 22/7/16.
//  Copyright © 2016 Charles. All rights reserved.
//

import UIKit

class CalculationTableViewController: UITableViewController {
    
    // MARK: - Properties
    var calculations = [Calculation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Load any saved calculations, otherwise load sample data.
        if let savedCalculations = loadCalculations() {
            calculations += savedCalculations
        } else {
            // load the sample data
            loadSampleCalculations()
        }
        
    }

    func loadSampleCalculations() {
        
        let calculation1 = Calculation(propertyAddress: "12 Hi San Rd, S 243565", purchasePrice: 1000800.00, nationality: 0, numProperty: 0, basicStampDuty: 300.00, additionalStampDuty: 50000.00, totalPrice: 1051000.00, photo: UIImage(named: "defaultPhoto")! )!
        let calculation2 = Calculation(propertyAddress: "34 Bubu Lane, S 167823", purchasePrice: 2000000.00, nationality: 0, numProperty: 0, basicStampDuty: 600.00, additionalStampDuty: 100000.00, totalPrice: 2100600.00, photo: UIImage(named: "defaultPhoto")! )!
        
        calculations += [calculation1, calculation2]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view celss are reused and should be dequeued usinga cell identifier
        let cellIdentifier = "CalculationTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CalculationTableViewCell

        // Fetches the appropriate calculation for the data source layout.
        let calculation = calculations[indexPath.row]
        
        cell.addressLabel.text = calculation.propertyAddress
        

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            calculations.removeAtIndex(indexPath.row)
            saveCalculations()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            let calculationDetailViewController = segue.destinationViewController as! CalculationDetailTableViewController
            
            // Get the cell that generated this segue.
            if let selectedCalculationCell = sender as? CalculationTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCalculationCell)!
                let selectedCalculation = calculations[indexPath.row]
                calculationDetailViewController.calculation = selectedCalculation
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new calculation.")
        }
        
    }

    @IBAction func unwindToCalculationList(sender: UIStoryboardSegue) {
        
        
        if let sourceViewController = sender.sourceViewController as? CalculationDetailTableViewController, calculation = sourceViewController.calculation {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing calculation.
                calculations[selectedIndexPath.row] = calculation
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None )
            } else {
                // Add a new calculation.
                let newIndexPath = NSIndexPath(forRow: calculations.count, inSection: 0)
                calculations.append(calculation)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            
            // Save the calculations.
            saveCalculations()
        }
    }
    
    // MARK: - NSCoding
    
    func saveCalculations() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(calculations, toFile: Calculation.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save calculations ...")
        }
    }
    
    func loadCalculations() -> [Calculation]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Calculation.ArchiveURL.path!) as? [Calculation]
    }
}
