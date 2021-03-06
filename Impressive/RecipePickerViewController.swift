//
//  RecipePickerViewController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 7/6/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class RecipePickerViewController: UITableViewController, UISplitViewControllerDelegate {
    
    
    @IBOutlet var sunSeparator: SunSeparator!
    
    
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
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // First, let's get our recipes loaded in.
        // The daily recipe is handled async, so here's a function that runs that and sets the variable:
        loadAndAddDaily(){}
        
        // The saved recipes are local and much simpler:
        savedRecipes = loadSavedRecipes()
        
        cellHasAppearedAt.append([])
        for _ in 0 ..< savedRecipes.count {
            cellHasAppearedAt[0].append(false)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        tableView.frame.origin.y = 0
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
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
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dailyIsPresent && section == 0 {
            return 1
        } else {
            return savedRecipes.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        if dailyIsPresent && indexPath.section == 0 {
            let dailyRecipeCell = tableView.dequeueReusableCellWithIdentifier("DailyRecipeCell", forIndexPath: indexPath) as! DailyRecipeCell
            dailyRecipeCell.recipe = dailyRecipe
            cell = dailyRecipeCell
        } else {
            let savedRecipeCell = tableView.dequeueReusableCellWithIdentifier("SavedRecipeCell", forIndexPath: indexPath) as! SavedRecipeCell
            savedRecipeCell.recipe = savedRecipes[indexPath.row]
            cell = savedRecipeCell
        }
        
        if !cellHasAppearedAt[indexPath.section][indexPath.row] {
            //Animate it in:
            let delay: NSTimeInterval = NSTimeInterval(350 + arc4random_uniform(200)) / 1000
            cell.animateIn(delay)
            cellHasAppearedAt[indexPath.section][indexPath.row] = true
        }
        
        return cell
    }
    
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if dailyIsPresent && section == 0 {
//            return ""
//        } else {
//            return "☀️"
//        }
//    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dailyIsPresent && section == 0 {
            return 0
        } else {
            return 64
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if dailyIsPresent && section == 0 {
            return nil
        } else {
            
            sunSeparator.sun.image = sunSeparator.sun.image?.imageWithRenderingMode(.AlwaysTemplate)
            sunSeparator.sun.tintColor = UIColor.coffeeColor()
            
            return sunSeparator
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if dailyIsPresent && indexPath.section == 0 {
            return 230
        } else {
            return 75
        }
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
//        for cell in tableView.visibleCells() as! [UITableViewCell] {
//            var point = tableView.convertPoint(cell.center, toView: tableView.superview)
//            cell.alpha = ((point.y * 100) / tableView.bounds.maxY) / 100
//        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseRecipeViewController = false
        
        // Only the daily recipe's prototype cell is hooked up to a segue in IB, so let's make sure the other recipe cells also fire it:
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? SavedRecipeCell {
            performSegueWithIdentifier("viewRecipe", sender: nil)
        }
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
                print("RECIPEPICKER: Adding a section for the daily recipe.")
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
        print("RECIPEPICKER: Time to figure out if our daily recipe is current.")
        
        if !LoadSave.sharedInstance.savedDailyIsCurrent() {
            
            print("RECIPEPICKER: Daily recipe is NOT current, attempting to load from the cloud.")
            
            LoadSave.sharedInstance.loadDaily() {
                dailyRecipe in
                
                print("RECIPEPICKER: Successfully loaded from cloud! Returning.")
                
                completion(daily: dailyRecipe)
            }
            
        } else {
            print("RECIPEPICKER: Daily recipe IS current, returning...")
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
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // First let's make our actions.
        
        // SAVE ACTION
        let saveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Save") {
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
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            Void in
            
            if self.dailyIsPresent && indexPath.section == 0 {

                self.tableView.beginUpdates()
                
                self.dailyIsPresent = false
                
                // Delete the daily saved in local storage.
                LoadSave.sharedInstance.deletePlist("SavedDaily")
                
                self.tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                
                self.tableView.endUpdates()
                
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
            
            // Create a recipe view to go to:
            let recipeVC = (segue.destinationViewController as! UINavigationController).topViewController as! RecipeViewController
            
            // Pass a recipe to it:
            if let selectedIndex = tableView.indexPathForSelectedRow {                
                if let selectedCell = tableView.cellForRowAtIndexPath(selectedIndex) as? RecipeCell {
                    recipeVC.recipe = selectedCell.recipe
                }
            }
        }
    }

    
    
    // MARK: UISplitViewControllerDelegate
    
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return collapseRecipeViewController
    }

}