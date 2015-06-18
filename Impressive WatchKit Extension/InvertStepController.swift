//
//  InvertStepController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 6/6/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class InvertStepController: WKInterfaceController {
    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var typeLabel: WKInterfaceLabel!

    
    //    var alreadySeen = false
    //    var animationLength: Int!
    var step: Step!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        step = context as! Step
        
        typeLabel.setText(step.type)
        
        //        stepGroup.setBackgroundImageNamed("TSwiftKarate") //Removed for the WWDC build.
        //        animationLength = 7
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        // Below logic removed for WWDC build. Some bits will be useful in the future.
        
        //        if !alreadySeen {
        //            alreadySeen = true
        //            println("HEATSTEPCONTROLLER: First time seeing.")
        //
        //            temperatureButton.setHidden(true)
        //
        //            // Kick off the animation:
        //            stepGroup.startAnimatingWithImagesInRange(
        //                NSRange(location: 0, length: animationLength),
        //                duration: 1,
        //                repeatCount: 1)
        //
        //            // Get ready to show whichever UI element:
        //            setTimerForFunction("showTemperature", seconds: 2)
        //
        //        } else {
        //            // Set the animation to the last frame (where it should have cleared the screen):
        //            println("HEATSTEPCONTROLLER: Already seen.")
        //            stepGroup.startAnimatingWithImagesInRange(
        //                NSRange(location: animationLength-1, length: 1),
        //                duration: 1,
        //                repeatCount: 1)
        //
        //            // Immediately show whichever UI element:
        //            showTemperature()
        //        }
        
    }
    
    override func didDeactivate() {
        // Below are commands that need to be wrapped in some sort of heuristics detection - a timer to determine whether the screen's being looked at by a user or by the system.
        
        //        alreadySeen = false
        //        temperatureButton.setHidden(true)
        
        super.didDeactivate()
    }
    
    
    // MISC
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }
    
}
