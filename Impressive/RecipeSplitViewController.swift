//
//  ViewController.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class RecipeSplitViewController: UISplitViewController {
    
    
    let animateIn = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if animateIn {
            // Set animation start points here:
            
            self.view.alpha = 0.0
            self.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
            self.view.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2)
            
            UIView.animateWithDuration(0.15, delay: 0.3, options: .CurveEaseOut, animations: {
                // Put animation end points here:
                
                self.view.alpha = 1.0
                self.view.transform = CGAffineTransformMakeScale(1, 1)
                
                }, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
