//
//  RecipePickerViewController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 7/6/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData

class RecipePickerViewController: UITableViewController, UISplitViewControllerDelegate {
    
    private var collapseRecipeViewController = true
    
    var dailyRecipe: Recipe!
    var dailyIsPresent = false
    var savedRecipes: [Recipe]!
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self

        // First, let's get our recipes loaded into the array.
        
        loadDailyRecipe()
        loadSavedRecipes()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if dailyIsPresent == true {
            return 2
        } else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dailyIsPresent == true {
            switch section {
                case 0:
                    return 1
                
                default:
                    return recipes.count - 1
            }
        } else {
            return recipes.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var recipe: Recipe
        
        if dailyIsPresent == true {
            switch indexPath.section {
            case 0:
                recipe = recipes[0]
                
            default:
                recipe = recipes[indexPath.row+1]
            }
        } else {
            recipe = recipes[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
        
        cell.nameLabel.text = recipe.name
        
        println("RECIPEPICKERVC: Creating a cell with name " + recipe.name + ".")
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseRecipeViewController = false
    }

    
    // MARK: Loading data
    
    
    func loadSavedRecipes() {
        // Load the saved recipes.
        savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
        
        // Add them to the recipes array.
        for recipe in savedRecipes {
            recipes.append(recipe)
        }
    }
    
    
    func reloadRecipes() {
        // Make sure the recipes array is empty:
        recipes = []
        
        // Add the daily recipe:
        dailyIsPresent = false
        loadDailyRecipe()
        
        // Now add the saved recipes:
        loadSavedRecipes()
        
        tableView.reloadData()
    }
    
    
    func loadDailyRecipe() {
        // Load the daily recipe, if current, elsewise pull down a new one from CK.
        
        println("RECIPEPICKERVC: Time to figure out if our daily recipe is current.")
        
        if !LoadSave.sharedInstance.savedDailyIsCurrent() {
            
            println("RECIPEPICKERVC: Daily recipe is NOT current, attempting to load from the cloud.")
            
            LoadSave.sharedInstance.loadDaily() {
                daily in
                self.dailyRecipe = daily
                println("RECIPEPICKERVC: Successfully loaded from cloud!")
                
                // Add it to the recipes array.
                self.recipes.insert(self.dailyRecipe, atIndex: 0)
                
                // Make note of the fact we have it:
                self.dailyIsPresent = true
                
                // We'll also add the row to the table, because by now cellForRowAtIndexPath has probably already been called.
                let indexSet = NSIndexSet(index: 0)
                self.tableView.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Bottom)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        } else {
            
            println("RECIPEPICKERVC: Daily recipe IS current, appending to recipes array.")
            dailyRecipe = LoadSave.sharedInstance.loadRecipe("SavedDaily")
            recipes.append(dailyRecipe)
            dailyIsPresent = true
            
        }
    }
    
    
    // MARK: Editing controls.
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // In case I ever want to disable edit actions on the daily recipe.
        if indexPath.row == 0 && LoadSave.sharedInstance.savedDailyIsCurrent() == true {
            return true
        } else {
            return true
        }
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        // First let's make our actions.
        
        // Save action:
        var saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Save") {
            Void in
            let recipeToSave = self.recipes[indexPath.row]
            
            // Save it:
            LoadSave.sharedInstance.saveRecipe(recipeToSave, inPlistNamed: "SavedRecipes")
            
            // Add it to our recipes array:
            self.recipes.append(recipeToSave)
            
            // And insert it into the second section.
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.recipes.count-2, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Top)
            
            // Reload the recipes.
//            self.reloadRecipes()
        }
        saveAction.backgroundColor = UIColor.greenColor()
        
        // Delete action:
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            Void in
            let recipeToDelete = self.recipes[indexPath.row]
            
            // First, delete the recipe from our current recipes array:
            self.recipes.removeAtIndex(indexPath.row)
            
            // Then delete the row from the table:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Finally, delete the recipe's saved data.
            if indexPath.row == 0 && LoadSave.sharedInstance.savedDailyIsCurrent() == true {
                // The daily recipe is stored in a separate plist:
                LoadSave.sharedInstance.deletePlist("SavedDaily")
            } else {
                // Delete the recipe from the SavedRecipes plist:
                LoadSave.sharedInstance.deleteRecipe(recipeToDelete, inPlistNamed: "SavedRecipes")
            }
            
            // And reload the recipes.
            self.reloadRecipes()
        }
        
        // Next, return the actions:
        if dailyIsPresent == true && indexPath.section == 0 {
            return [saveAction, deleteAction]
        } else {
            return [deleteAction]
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        // Get the moved recipe's data from the array...
        let movedRecipe = recipes[fromIndexPath.row]
        
        // ...and move it to its new position:
        recipes.removeAtIndex(fromIndexPath.row)
        recipes.insert(movedRecipe, atIndex: toIndexPath.row)
        
        // Then save the re-ordered recipes array:
        LoadSave.sharedInstance.overwriteRecipesInPlist("SavedRecipes", withRecipes: recipes)
    }

    
    // Override to support conditional rearranging.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // Let's make sure the daily recipe isn't rearrangeable.
        if dailyIsPresent == true && indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }

    
    /*
    // MARK: Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: UISplitViewControllerDelegate
    
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseRecipeViewController
    }

}
