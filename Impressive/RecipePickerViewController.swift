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

    @IBOutlet weak var deleteDailyButton: UIButton!
    
    private var collapseRecipeViewController = true
    
    var dailyRecipe: Recipe!
    var savedRecipes: [Recipe]!
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
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
                
                // AND THEN add the row to the table.
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        } else {
            println("RECIPEPICKERVC: Daily recipe IS current, appending to recipes array.")
            dailyRecipe = LoadSave.sharedInstance.loadRecipe("SavedDaily")
            recipes.append(dailyRecipe)
        }
        
        // Load the saved recipes.
        savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
        
        // Add them to the recipes array.
        for recipe in savedRecipes {
            recipes.append(recipe)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return recipes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeCell", forIndexPath: indexPath) as! RecipeCell

        // Configure the cell...
        let currentRecipe: Recipe = recipes[indexPath.row]
        cell.nameLabel.text = currentRecipe.name
        println("RECIPEPICKERVC: Creating a cell with name " + currentRecipe.name + ".")

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseRecipeViewController = false
        
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func deleteDailyPressed(sender: AnyObject) {
        LoadSave.sharedInstance.deletePlist("SavedDaily")
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseRecipeViewController
    }

}
