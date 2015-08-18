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
    var cellHasAppearedAt = [[Bool]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        
        self.clearsSelectionOnViewWillAppear = false
        self.title = " "
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // First, let's get our recipes loaded in.
        // The daily recipe is handled async, so here's a function that runs that and sets the variable:
        loadAndAddDaily(){}
        
        // The saved recipes are local and much simpler:
        savedRecipes = loadSavedRecipes()
        
        cellHasAppearedAt.append([])
        for i in 0 ..< savedRecipes.count {
            cellHasAppearedAt[0].append(false)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: Table view data source.
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if dailyIsPresent == true {
            if cellHasAppearedAt.count < 2 {
                cellHasAppearedAt.insert([false], atIndex: 0)
            }
            return 2
        } else {
            if cellHasAppearedAt.count > 1 {
                cellHasAppearedAt.removeAtIndex(0)
            }
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
        var recipe: Recipe
        
        let screenWidth = self.view.bounds.width
        var offscreen: CGRect!
        var damping: CGFloat!
        
        // Figure out which type of cell it is:
        if dailyIsPresent && indexPath.section == 0 {
            
            cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
            recipe = dailyRecipe
            cell.nameLabel.text = recipe.name + ", today's special!"
            
            damping = 0.7
            offscreen = CGRect(x: cell.frame.origin.x + screenWidth/2, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
            
        } else {
            
            cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell
            recipe = savedRecipes[indexPath.row]
            cell.nameLabel.text = recipe.name
            
            damping = 0.7
            offscreen = CGRect(x: cell.frame.origin.x - screenWidth/2, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
        }
        
        if !cellHasAppearedAt[indexPath.section][indexPath.row] {
            // Animate it.
            // Set starting parameters:
            let destination = cell.frame
            cell.frame = offscreen
            cell.alpha = 0.0
    //        cell.transform = CGAffineTransformMakeScale(0.75, 1)
            
            // Randomize the delay:
            let delay: NSTimeInterval = NSTimeInterval(350 + arc4random_uniform(200)) / 1000
            
            // Animations:
            UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.65, options: .CurveEaseInOut, animations: {
                cell.frame = destination
    //            cell.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
            
            UIView.animateWithDuration(0.85, delay: delay, options: .CurveLinear, animations: {
                cell.alpha = 1.0
            }, completion: nil)
            
            cellHasAppearedAt[indexPath.section][indexPath.row] = true
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseRecipeViewController = false
    }

    
    
    // MARK: Loading data
    
    
    func reloadSavedRecipes() {
        savedRecipes = loadSavedRecipes()
        tableView.reloadData()
    }
    
    
    func loadAndAddDaily(completion: () -> ()) {
        loadDailyRecipe() {
            daily in
            
            if self.dailyIsPresent {
                self.tableView.beginUpdates()
                self.dailyRecipe = daily
                self.tableView.endUpdates()
            } else {
                println("RECIPEPICKER: Adding a section for the daily recipe.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.beginUpdates()
                    
                    self.tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                    
                    self.dailyRecipe = daily
                    self.dailyIsPresent = true
                    
                    self.tableView.endUpdates()
                }
            }

            completion()
        }
    }
    
    
    func loadSavedRecipes() -> [Recipe] {
        // Load the saved recipes.
        return LoadSave.sharedInstance.loadRecipes("SavedRecipes")
    }
    
    
    func loadDailyRecipe(completion: (daily: Recipe) -> Void) {
        // Load the daily recipe, if current, elsewise pull down a new one from CK.
        println("RECIPEPICKER: Time to figure out if our daily recipe is current.")
        
        if !LoadSave.sharedInstance.savedDailyIsCurrent() {
            
            println("RECIPEPICKER: Daily recipe is NOT current, attempting to load from the cloud.")
            
            LoadSave.sharedInstance.loadDaily() {
                dailyRecipe in
                
                println("RECIPEPICKER: Successfully loaded from cloud! Returning.")
                
                completion(daily: dailyRecipe)
            }
            
        } else {
            println("RECIPEPICKER: Daily recipe IS current, returning...")
            dailyIsPresent = true
            completion(daily: LoadSave.sharedInstance.loadRecipe("SavedDaily"))
        }
    }
    
    
    
    // MARK: Editing controls.
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.dailyIsPresent = false
        self.loadAndAddDaily() {
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    @IBAction func restoreDefaultsButton(sender: AnyObject) {
        LoadSave.sharedInstance.deletePlist("SavedRecipes")
        reloadSavedRecipes()
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        // First let's make our actions.
        
        // SAVE ACTION
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
            
            self.tableView.beginUpdates()
            
            // Save it to local storage:
            LoadSave.sharedInstance.saveRecipe(recipeToSave, inPlistNamed: "SavedRecipes")
            
            // Add it to our saved recipes array:
            self.savedRecipes.append(recipeToSave)
            
            // Don't forget to keep track of its animation:
            self.cellHasAppearedAt[targetSection].append(false)
            
            // And insert a cell into the appropriate section:
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.savedRecipes.count-1, inSection: targetSection)], withRowAnimation: UITableViewRowAnimation.Top)

            self.tableView.endUpdates()
            
            // Finally, let's leave the editing mode:
            self.tableView.setEditing(false, animated: true)
        }
        saveAction.backgroundColor = UIColor.greenColor()
        
        // DELETE ACTION
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            Void in
            
            if self.dailyIsPresent && indexPath.section == 0 {
                
                self.tableView.beginUpdates()
                
                self.dailyIsPresent = false
                
                // Delete the daily saved in local storage.
                LoadSave.sharedInstance.deletePlist("SavedDaily")
                
                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                
                self.tableView.endUpdates()
                
                // Don't forget to remove it from the index of cells that have animated:
                self.cellHasAppearedAt.removeAtIndex(0)
                
            } else {
                
                self.tableView.beginUpdates()
                
                // Identify the recipe to delete.
                let recipeToDelete = self.savedRecipes[indexPath.row]
                
                // Delete the recipe from our array:
                self.savedRecipes.removeAtIndex(indexPath.row)
                
                // Delete the recipe from local storage:
                LoadSave.sharedInstance.deleteRecipe(recipeToDelete, inPlistNamed: "SavedRecipes")
                
                // Then delete the row from the table:
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
                self.tableView.endUpdates()
                
                // Don't forget to remove it from the index of cells that have animated:
                self.cellHasAppearedAt[indexPath.section].removeAtIndex(indexPath.row)

            }
        }
        
        // Next, return the actions:
        if dailyIsPresent == true && indexPath.section == 0 {
            return [saveAction, deleteAction]
        } else {
            return [deleteAction]
        }
    }
    
    
    // Allow editing the table view:
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    // Restrict editing by section:
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // In case I ever want to disable edit actions on the daily recipe.
        if indexPath.section == 0 && dailyIsPresent {
            return true
        } else {
            return true
        }
    }
    

    // Allow rearranging the table view:
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // Get the moved recipe's data from the array...
        let movedRecipe = savedRecipes[fromIndexPath.row]
        
        // ...and move it to its new position:
        savedRecipes.removeAtIndex(fromIndexPath.row)
        savedRecipes.insert(movedRecipe, atIndex: toIndexPath.row)
        
        // Then save the re-ordered recipes array:
        LoadSave.sharedInstance.overwriteRecipesInPlist("SavedRecipes", withRecipes: savedRecipes)
    }
    
    
    // Restrict rearranging by section:
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

    
    // Restrict rearranging by section number:
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // Let's make sure the daily recipe isn't rearrangeable.
        if dailyIsPresent && indexPath.section == 0 {
            return false
        } else {
            return true
        }
    }
    
    
    
    // MARK: Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Handle segues.
        
        // First, for selecting a recipe:
        if segue.identifier == "viewRecipe" {
            
            var recipevc = segue.destinationViewController.topViewController as! RecipeViewController
            
            if let selectedIndex = tableView.indexPathForSelectedRow() {
            
                if dailyIsPresent && selectedIndex.section == 0 {
                    println("RECIPEPICKER: Daily recipe selected, sending it on over to the recipe view.")
                    recipevc.recipe = dailyRecipe
                
                } else {
                    println("RECIPEPICKER: A saved recipe was selected, sending it on over to the recipe view.")
                    recipevc.recipe = savedRecipes[selectedIndex.row]
                }
            }
        }
    }

    
    
    // MARK: UISplitViewControllerDelegate
    
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseRecipeViewController
    }

}