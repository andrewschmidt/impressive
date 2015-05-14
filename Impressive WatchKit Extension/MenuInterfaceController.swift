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
    var specialRecipe: Recipe!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
//        loadTableData()
        
        // What's below is great. Need to decide the best way to refactor it into its own function (or pair of functions). But cool! Communication with the main app is working!
        
        // Let's try fetching our personal recipes from the cloud, via the iPhone app.
//        let request = ["fetchPersonalRecipes":"overwrite"]
//        
//        println("MENUIC: Attempting to contact parent app.")
//        WKInterfaceController.openParentApplication(request) {
//            (reply, error) -> Void in
//            
//            if error != nil {
//                println(error)
//                
//            } else {
//                println(reply["success"]!)
//                self.loadTableData()
//                
//            }
//        }
        
    }
    
    
    private func loadTableData() {
        
        // WHOA. I NEED to nest most of this in a completion block - this could be why it's so hard to get the app running!
        
        // First let's load our pick of the day & saved recipes.
        specialRecipe = LoadSave.sharedInstance.loadRecipe("SpecialRecipe")
        savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
        
        // Let's create an array of our row types. The first row is always our daily special:
        var rowTypes = ["SpecialTableRowController"]
        
        // The rest of the rows are the regular row type:
        for recipe in savedRecipes {
            rowTypes.append("MenuTableRowController")
        }
        
        // Finally set the row types:
        recipeTable.setRowTypes(rowTypes)
        
        // Set the label of the special recipe:
        let specialRow = recipeTable.rowControllerAtIndex(0) as! SpecialTableRowController
        specialRow.specialNameLabel.setText(specialRecipe.name)
        
        // And set the labels of the saved recipes:
        for (index, currentRecipe) in enumerate(savedRecipes) {
            
            // We need to adjust the index number, because the first row is already taken care of:
            let adjustedIndex = index+1
            
            let row = recipeTable.rowControllerAtIndex(adjustedIndex) as! MenuTableRowController

            row.recipeNameLabel.setText(currentRecipe.name)
        }
    }
    
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        var selectedRecipe: Recipe!
        
        if rowIndex == 0 {
            selectedRecipe = specialRecipe
        }
        else {
            var adjustedRowIndex = rowIndex-1
            selectedRecipe = savedRecipes[adjustedRowIndex]
        }
        
//         let controllers: [String] = Array(count: selectedRecipe.steps.count, repeatedValue: "StepsInterfaceController")
        
        var controllers = [String]()
                
        for step in selectedRecipe.steps {
            let controller = step.type + "Step"
            controllers.append(controller)
        }
        
        presentControllerWithNames(controllers, contexts: selectedRecipe.steps)

    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        loadTableData()
        
        super.willActivate()
    }

    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
