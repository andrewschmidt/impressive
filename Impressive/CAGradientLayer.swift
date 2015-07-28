////
////  CAGradientLayer.swift
////  Daily Press
////
////  Created by Andrew Schmidt on 7/26/15.
////  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
////
//
//import UIKit
//
//extension CAGradientLayer {
//
//    func turquoiseColor() -> CAGradientLayer {
//        println("CAGRADIENTLAYER: Time for turquoise!")
//        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
//        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
//        
//        let gradientColors: Array <AnyObject> = [topColor.CGColor, bottomColor.CGColor]
//        let gradientLocations: Array <AnyObject> = [0.0, 1.0]
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientColors
//        gradientLayer.locations = gradientLocations
//        
//        return gradientLayer
//    }
//}