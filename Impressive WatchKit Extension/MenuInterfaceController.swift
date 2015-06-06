//
//  InterfaceController.swift
//  Impressive WatchKit Extension
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//
//  Colors
//  Coffee Brown (buttons): #3B1C18 (Current), #24120F, #311713, #563E33
//  Soy Cream (text): #FFFFEB
//  Lindsay Blue (accent): #84D5B6

import WatchKit
import Foundation
import ImpData

class MenuInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var recipeTable: WKInterfaceTable!
    var savedRecipes = [Recipe]()
    var dailyRecipe: Recipe!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Let's ask the iPhone app to load our daily recipe before we populate the table.
        // Not sure if this is really the right view to do this in, but it's worth a shot!
        
        if !LoadSave.sharedInstance.savedDailyIsCurrent() {
            println("\rMENUIC: The saved daily recipe is not current.")
            println("MENUIC: Attempting to contact the parent app to load a daily recipe.")
            
            let request = ["loadDaily":""]
            
            WKInterfaceController.openParentApplication(request) {
                (reply, error) -> Void in
                
                if error != nil {
                    println(error)
                } else {
                    println(reply["success"]!)
                    self.loadTableData()
                }
            }
        } else {
            println("\rMENUIC: The saved daily recipe is current, moving on...")
            self.loadTableData()
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
//        loadTableData()
        
        super.willActivate()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    private func loadTableData() {
        
        // First let's load our pick of the day & saved recipes.
        dailyRecipe = LoadSave.sharedInstance.loadRecipe("SavedDaily")
        savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
        
        // Let's create an array of our row types. The first row is always our daily special:
        var rowTypes = ["SpecialTableRowController"]
        
        // The rest of the rows are the regular row type:
        for recipe in savedRecipes {
            rowTypes.append("MenuTableRowController")
        }
        
        // Finally set the row types:
//        recipeTable.setRowTypes(rowTypes)
        
        // Set the label of the special recipe:
        recipeTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "SpecialTableRowController")
        
        let dailyRow = recipeTable.rowControllerAtIndex(0) as! SpecialTableRowController
        dailyRow.specialNameLabel.setText(dailyRecipe.name)
        
        
        // And set the labels of the saved recipes:
        for (index, currentRecipe) in enumerate(savedRecipes) {
            
            // We need to adjust the index number, because the first row is already taken care of:
            let adjustedIndex = index+1
            
            // Then add the row:
            recipeTable.insertRowsAtIndexes(NSIndexSet(index: adjustedIndex), withRowType: "MenuTableRowController")

            let row = recipeTable.rowControllerAtIndex(adjustedIndex) as! MenuTableRowController
            row.recipeNameLabel.setText(currentRecipe.name)
        }
    }
    
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        var selectedRecipe: Recipe!
        
        if rowIndex == 0 {
            selectedRecipe = dailyRecipe
        }
        else {
            var adjustedRowIndex = rowIndex-1
            selectedRecipe = savedRecipes[adjustedRowIndex]
        }
                
        var controllers = [String]()
        
        for step in selectedRecipe.steps {
            let controller = step.type + "Step"
            controllers.append(controller)
        }
        
        presentControllerWithNames(controllers, contexts: selectedRecipe.steps)

    }

    

}
