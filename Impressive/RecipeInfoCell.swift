//
//  RecipeInfoCell.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit



class RecipeInfoCell: UITableViewCell {

    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var brewerLabel: UILabel!
    
    private var _recipe: Recipe!
    var recipe: Recipe {
        get {
            return _recipe
        }
        set(newValue) {
            _recipe = newValue
            configureCell()
        }
    }
    
    
    override func animateIn(delay: NSTimeInterval) {
        super.animateIn(delay) // This takes care of the fade-in.
        
        let damping: CGFloat = 0.8
        let velocity: CGFloat = 0.3
        
        _ = self.superview!.bounds.width
        let endFrame: CGRect = self.frame
        let startFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y+10, width: self.frame.width, height: self.frame.height)
        
        // Set starting values:
        self.frame = startFrame
        
        // Animations:
        UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .CurveEaseInOut, animations: {
            self.frame = endFrame
        }, completion: nil)
    }
    

    func configureCell() {
        // Set up our cell:
        self.recipeNameLabel.text = recipe.name
        self.authorLabel.text = recipe.author
        self.brewerLabel.text = recipe.brewer
    }
}
