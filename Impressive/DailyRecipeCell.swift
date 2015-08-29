//
//  DailyRecipeCell.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 8/28/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class DailyRecipeCell: UITableViewCell {

    
    @IBOutlet weak var pickOfTheDayLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func animateIn(delay: NSTimeInterval) {
        super.animateIn(delay) // This takes care of the fade-in.
        
        var damping: CGFloat = 0.7
        
        let screenWidth = self.superview!.bounds.width
        
        let pickOfTheDayDestination = pickOfTheDayLabel.frame
        let pickOfTheDayStart = CGRect(x: pickOfTheDayLabel.frame.origin.x, y: nameLabel.frame.origin.y + 2, width: pickOfTheDayLabel.frame.width, height: pickOfTheDayLabel.frame.height)
        
        // Set starting values:
        pickOfTheDayLabel.frame = pickOfTheDayStart
        nameLabel.transform = CGAffineTransformMakeScale(0.85, 0.85)
        
        // Animations:
        UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.65, options: .CurveEaseInOut, animations: {
            self.pickOfTheDayLabel.frame = pickOfTheDayDestination
            self.nameLabel.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: nil)
    }

}
