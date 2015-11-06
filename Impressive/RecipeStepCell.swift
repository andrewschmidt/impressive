//
//  RecipeStepCell.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class RecipeStepCell: UITableViewCell {

    
    @IBOutlet weak var stepTypeLabel: UILabel!
    @IBOutlet weak var stepValueLabel: UILabel!
    
    override func animateIn(delay: NSTimeInterval) {
        super.animateIn(delay) // This takes care of the fade-in.
        
        let damping: CGFloat = 0.8
        let velocity: CGFloat = 0.3
        
        let screenWidth = self.superview!.bounds.width
        let endFrame: CGRect = self.frame
        let startFrame = CGRect(x: self.frame.origin.x + screenWidth/5, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        
        // Set starting values:
        self.frame = startFrame
        
        // Animations:
        UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .CurveEaseInOut, animations: {
            self.frame = endFrame
            }, completion: nil)
    }

}
