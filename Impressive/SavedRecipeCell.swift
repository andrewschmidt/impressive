//
//  SavedRecipeCell.swift
//  Impressive
//
//  Created by Andrew Schmidt on 7/6/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData

class SavedRecipeCell: UITableViewCell, RecipeCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var _recipe: Recipe!
    var recipe: Recipe {
        get {
            return _recipe
        }
        set(newVal) {
            _recipe = newVal
            self.nameLabel.text = newVal.name
        }
    }
    
    
    override func animateIn(delay: NSTimeInterval) {
        super.animateIn(delay) // This takes care of the fade-in.
        
        var damping: CGFloat = 0.7
        
        let screenWidth = self.superview!.bounds.width
        let endFrame: CGRect = nameLabel.frame
        var startFrame = CGRect(x: nameLabel.frame.origin.x - screenWidth/2, y: nameLabel.frame.origin.y, width: nameLabel.frame.width, height: nameLabel.frame.height)
        
        // Set starting values:
        nameLabel.frame = startFrame
        
        // Animations:
        UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.65, options: .CurveEaseInOut, animations: {
            self.nameLabel.frame = endFrame
        }, completion: nil)
    }
    
}
