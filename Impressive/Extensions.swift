//
//  Extensions.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 8/28/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
        
    func animateIn(delay: NSTimeInterval) {
        // Here are the things a UITableViewCell should *always* do when animating:
        self.alpha = 0.0
        
        UIView.animateWithDuration(0.85, delay: delay, options: .CurveLinear, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
}