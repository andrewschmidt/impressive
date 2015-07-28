//
//  ViewController.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/10/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class RecipeSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        // Set animation start points here.
        
//        self.view.alpha = 0.0
        
//        let screenSize = UIScreen.mainScreen().bounds
//        let startSize = CGRectMake(0.0, 0.0, screenSize.width-100, screenSize.height*0.75)
        
//        self.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
//        self.view.frame = CGRectMake(self.view.frame.x*0.5, self.view.frame.y*0.5, self.view.frame.width, self.view.frame.height)
        
    }
    
    override func viewWillAppear(animated: Bool) {
//        UIView.animateWithDuration(1.5) {
//            // Put animations here.
//            
////            self.view.alpha = 1.0
////            self.view.transform = CGAffineTransformMakeScale(1, 1)
//            
//            
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
