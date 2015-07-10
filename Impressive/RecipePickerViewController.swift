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
    var savedRecipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self

        // First, let's get our recipes loaded in.
        
        loadDailyRecipe() {
            daily in
            self.dailyRecipe = daily
            self.dailyIsPresent = true
            
            // We'll also add the row to the table, because by now cellForRowAtIndexPath has probably already been called.
            self.tableView.beginUpdates()
            self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.endUpdates()
        }
        
        savedRecipes = loadSavedRecipes()
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dailyIsPresent && section == 0 {
            return "Pick of the Day"
        } else {
            return "Saved Recipes"
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dailyIsPresent && section == 0 {
            return 1
        } else {
            return savedRecipes.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: RecipeCell
        var cellRecipe: Recipe
        
        if dailyIsPresent == true && indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
            cellRecipe = dailyRecipe
            cell.nameLabel.text = cellRecipe.name + ", today's special!"
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
            cellRecipe = savedRecipes[indexPath.row]
            cell.nameLabel.text = cellRecipe.name
        }
        
        println("RECIPEPICKERVC: Creating a cell with name " + cellRecipe.name + ".")
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseRecipeViewController = false
    }

    
    // MARK: Loading data
    
    
    func loadSavedRecipes() -> [Recipe] {
        // Load the saved recipes.
        return LoadSave.sharedInstance.loadRecipes("SavedRecipes")
    }
    
    
    func reloadRecipes() {
        // Reload the saved recipes:
        savedRecipes = loadSavedRecipes()
        
        // Reload the daily recipe:
        dailyIsPresent = false
        loadDailyRecipe() {
            daily in
            self.dailyRecipe = daily
            self.dailyIsPresent = true
            
            // We'll also add the row to the table, because by now cellForRowAtIndexPath has probably already been called.
//            self.tableView.beginUpdates()
            self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
//            self.tableView.endUpdates()
            
        }
        
        tableView.reloadData()
    }
    
    
    func loadDailyRecipe(completion: (daily: Recipe) -> Void) {
        // Load the daily recipe, if current, elsewise pull down a new one from CK.
        
        println("RECIPEPICKERVC: Time to figure out if our daily recipe is current.")
        
        if !LoadSave.sharedInstance.savedDailyIsCurrent() {
            
            println("RECIPEPICKERVC: Daily recipe is NOT current, attempting to load from the cloud.")
            
            LoadSave.sharedInstance.loadDaily() {
                dailyRecipe in
                
                println("RECIPEPICKERVC: Successfully loaded from cloud! Returning.")
                                
                completion(daily: dailyRecipe)
            }
            
        } else {
            
            println("RECIPEPICKERVC: Daily recipe IS current, returning...")
            dailyIsPresent = true
            completion(daily: LoadSave.sharedInstance.loadRecipe("SavedDaily"))
//            return LoadSave.sharedInstance.loadRecipe("SavedDaily")
            
        }
    }
    
    
    // MARK: Editing controls.
    

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // In case I ever want to disable edit actions on the daily recipe.
        if indexPath.section == 0 && dailyIsPresent {
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
            
            // Figure out which recipe to save:
            var recipeToSave: Recipe
            
            if indexPath.section == 0 && self.dailyIsPresent == true {
                recipeToSave = self.dailyRecipe
            } else {
                recipeToSave = self.savedRecipes[indexPath.row]
            }
            
            // Figure out where to add a cell:
            var targetSection: Int
            
            if self.dailyIsPresent {
                targetSection = 1
            } else {
                targetSection = 0
            }
            
            // Save it to local storage:
            LoadSave.sharedInstance.saveRecipe(recipeToSave, inPlistNamed: "SavedRecipes")
            
            // Add it to our saved recipes array:
            self.savedRecipes.append(recipeToSave)
            
            // And insert a cell into the appropriate section:
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.savedRecipes.count-1, inSection: targetSection)], withRowAnimation: UITableViewRowAnimation.Top)
        }
        saveAction.backgroundColor = UIColor.greenColor()
        
        // Delete action:
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            Void in
            
            if self.dailyIsPresent && indexPath.section == 0 {
                // Delete the daily saved in local storage.
                LoadSave.sharedInstance.deletePlist("SavedDaily")
                self.dailyIsPresent = false
                tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                
            } else {
                // Identify the recipe to delete.
                let recipeToDelete = self.savedRecipes[indexPath.row]
                
                // Delete the recipe from our array:
                self.savedRecipes.removeAtIndex(indexPath.row)
                
                // Delete the recipe from local storage:
                LoadSave.sharedInstance.deleteRecipe(recipeToDelete, inPlistNamed: "SavedRecipes")
                
                // Then delete the row from the table:
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
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
        let movedRecipe = savedRecipes[fromIndexPath.row]
        
        // ...and move it to its new position:
        savedRecipes.removeAtIndex(fromIndexPath.row)
        savedRecipes.insert(movedRecipe, atIndex: toIndexPath.row)
        
        // Then save the re-ordered recipes array:
        LoadSave.sharedInstance.overwriteRecipesInPlist("SavedRecipes", withRecipes: savedRecipes)
    }
    
    
    override func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = tableView.numberOfRowsInSection(sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
            
        } else {
            return proposedDestinationIndexPath
        }
    }

    
    // Override to support conditional rearranging.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // Let's make sure the daily recipe isn't rearrangeable.
        if dailyIsPresent && indexPath.section == 0 {
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
