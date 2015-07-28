
//
//  GradientView.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/27/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
    func withColors(topColor: UIColor, _ bottomColor: UIColor) {
        
        let deviceScale = UIScreen.mainScreen().scale
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width * deviceScale, self.frame.size.height * deviceScale)
        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }

}
