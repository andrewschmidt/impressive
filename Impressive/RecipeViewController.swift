//
//  RecipeViewController.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class RecipeViewController: UITableViewController {
    
    
    
    var recipe: Recipe!
    var cellHasAppearedAt = [[Bool]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if recipe == nil {
            let savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
            recipe = savedRecipes[0]
        }
        
        startAnimationTracker()
    }
    
    
    func startAnimationTracker() {
        // This sets up the array for tracking which cells have appeared, 
        // and starts a timer for the animation window during which their appearance should be animated.
        
        cellHasAppearedAt.append([false]) // This is the boolean for the title cell.
        cellHasAppearedAt.append([])
        for _ in 0 ..< recipe.steps.count {
            cellHasAppearedAt[1].append(false)  // These will be the booleans for the rest.
        }
        
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("stopAnimations"), userInfo: nil, repeats: false)
    }
    
    
    func stopAnimations() {
        // Once enough time has passed that we're confident all the cells on screen have started animating, let's close the animation window:
        for i in 0 ..< recipe.steps.count {
            cellHasAppearedAt[1][i] = true
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            // Return the recipe info cell.
            let infoCell = tableView.dequeueReusableCellWithIdentifier("recipeInfoCell", forIndexPath: indexPath) as! RecipeInfoCell
            infoCell.recipe = recipe
            cell = infoCell
            
        } else {
            // Return a step cell.
            let stepCell = tableView.dequeueReusableCellWithIdentifier("recipeStepCell", forIndexPath: indexPath) as! RecipeStepCell
            stepCell.step = recipe.steps[indexPath.row]
            cell = stepCell
        }
        
        if !cellHasAppearedAt[indexPath.section][indexPath.row] {
            // Animate it in:
            let delay: NSTimeInterval = NSTimeInterval(200 + arc4random_uniform(100)) / 1000
            cell.animateIn(delay)
            cellHasAppearedAt[indexPath.section][indexPath.row] = true
        }
        
        return cell
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
