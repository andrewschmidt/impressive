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
    
    
    
    var recipe: Recipe!
    var cellHasAppearedAt = [[Bool]]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if recipe == nil {
            let savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
            recipe = savedRecipes[0]
        }
        
        cellHasAppearedAt.append([false])
        cellHasAppearedAt.append([])
        for i in 0 ..< recipe.steps.count {
            cellHasAppearedAt[1].append(false)
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
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        var originFrame: CGRect!
        
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            // Configure the recipe info cell.
            var infoCell = tableView.dequeueReusableCellWithIdentifier("recipeInfoCell", forIndexPath: indexPath) as! RecipeInfoCell
            
            infoCell.recipeNameLabel.text = recipe.name
            infoCell.authorLabel.text = recipe.author
            infoCell.brewerLabel.text = recipe.brewer
            
            cell = infoCell
            
            originFrame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y+10, width: cell.frame.width, height: cell.frame.height)
            
        } else {
            // Configure each step's cell.
            var stepCell = tableView.dequeueReusableCellWithIdentifier("recipeStepCell", forIndexPath: indexPath) as! RecipeStepCell
            let step = recipe.steps[indexPath.row]
            let value = step.value
            
            stepCell.stepTypeLabel.text = step.type
            stepCell.stepValueLabel.text = String(format:"%.f", value)
            
            cell = stepCell
            
            originFrame = CGRect(x: cell.frame.origin.x + screenWidth/5, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
        }
        
        if !cellHasAppearedAt[indexPath.section][indexPath.row] {
            // Animate it in:
            let destination = cell.frame
            cell.frame = originFrame
            cell.alpha = 0.0
            
            let delay: NSTimeInterval = NSTimeInterval(200 + arc4random_uniform(100)) / 1000
            
            UIView.animateWithDuration(1.0, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .CurveEaseInOut, animations: {
                cell.frame = destination
                cell.alpha = 1.0
            }, completion: nil)
            
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
