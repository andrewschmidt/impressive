//
//  RecipeViewController.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData

class RecipeViewController: UITableViewController {
    
    
    @IBOutlet var gradientView: GradientView!
    
    var recipe: Recipe!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .clearColor()
        self.tableView.backgroundView = gradientView
        
        if recipe == nil {
            let savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
            recipe = savedRecipes[0]
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        self.gradientView.withColors(UIColor.whiteColor(), UIColor.orangeColor())
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: Table view data source

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return recipe.steps.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            // Configure the recipe info cell.
            let cell = tableView.dequeueReusableCellWithIdentifier("recipeInfoCell", forIndexPath: indexPath) as! RecipeInfoCell
            
            cell.backgroundColor = .clearColor()
            cell.recipeNameLabel.text = recipe.name
            cell.authorLabel.text = recipe.author
            cell.brewerLabel.text = recipe.brewer
            
            return cell

        } else {
            // Configure each step's cell.
            let cell = tableView.dequeueReusableCellWithIdentifier("recipeStepCell", forIndexPath: indexPath) as! RecipeStepCell
            let step = recipe.steps[indexPath.row]
            let value = step.value
            
            cell.backgroundColor = .clearColor()
            cell.stepTypeLabel.text = step.type
            cell.stepValueLabel.text = String(format:"%.f", value)
            
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 166
        } else {
            return 99
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return "Steps"
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
    }


    
    // MARK: Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
