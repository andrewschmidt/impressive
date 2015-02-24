//
//  InterfaceController.swift
//  Impressive WatchKit Extension
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation


class MenuInterfaceController: WKInterfaceController {

    @IBOutlet weak var recipeTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        loadTableData()
    }
    
    private func loadTableData() {
        recipeTable.setNumberOfRows(savedRecipes.count, withRowType: "MenuTableRowController")
        
        for (index, currentRecipe) in enumerate(savedRecipes) {
            let row = recipeTable.rowControllerAtIndex(index) as MenuTableRowController

            row.recipeNameLabel.setText(currentRecipe.name)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let selectedRecipe = savedRecipes[rowIndex]
        
        let controllers = Array(count: selectedRecipe.steps.count, repeatedValue: "StepsInterfaceController")
        
        presentControllerWithNames(controllers, contexts: selectedRecipe.steps)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
