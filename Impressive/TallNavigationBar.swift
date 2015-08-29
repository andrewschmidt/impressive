//
//  TallNavigationBar.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 8/28/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class TallNavigationBar: UINavigationBar {

    // Taken from: http://stackoverflow.com/questions/20484381/in-ios-7-if-i-hide-the-status-bar-with-the-prefersstatusbarhidden-method-the
        
    override func sizeThatFits(size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        
        if UIApplication.sharedApplication().statusBarHidden {
            size.height = 64
        }
        
        return size
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}