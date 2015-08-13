
//
//  GradientView.swift
//  Daily Press
//
//  Created by Andrew Schmidt on 7/27/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    var gradientLayer: CAGradientLayer!
    
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
    
    
    private func changeColors(topColor: UIColor, _ bottomColor: UIColor) {
        
        let originalColors = gradientLayer.colors
        let newColors = [topColor.CGColor, bottomColor.CGColor]
        
        let animation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = originalColors
        animation.toValue = newColors
        
        animation.duration = 3.0
        animation.removedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.repeatCount = 1
        
        self.gradientLayer.colors = newColors
        
        gradientLayer.addAnimation(animation, forKey: "colors")
    }
    
    
    func withColors(topColor: UIColor, _ bottomColor: UIColor) {
        gradientLayer = CAGradientLayer()
        let deviceScale = UIScreen.mainScreen().scale
        gradientLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width * deviceScale, self.frame.size.height * deviceScale)
        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // Let's kick off an animation right now, just for fun:
        // Maybe adjust this to be changeColorsOfLayer(layer: , toColors: , duration: )
        changeColors(.lightGrayColor(), .purpleColor())
    }
}