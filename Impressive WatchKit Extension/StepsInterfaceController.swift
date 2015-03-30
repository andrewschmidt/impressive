//
//  RecipeStepsInterfaceController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class StepsInterfaceController: WKInterfaceController {

    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var actionLabel: WKInterfaceLabel!
    @IBOutlet weak var timerDoneLabel: WKInterfaceLabel!
    
    
    var alreadySeen = false
    var animationLength = 7
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var step = context as Step
        
        actionLabel.setText(step.type)
        
        // Below is a switch to perform custom UI commands depending on the step type. I'd like to name each animation the same as the step's type, so we won't need a Switch statement to handle those — but I bet we'll still need it to do things like create timers on buttons, etc.
        
        switch step.type {
            case "Heat":
                stepGroup.setBackgroundImageNamed("TSwiftKarate")
                animationLength = 7

            case "Pour":
                stepGroup.setBackgroundImageNamed("Mushroom")
                animationLength = 20

            case "Stir":
                stepGroup.setBackgroundImageNamed("TSwiftKarate")
                animationLength = 7
            
            case "Press":
                stepGroup.setBackgroundImageNamed("TSwiftKarate")
                animationLength = 7
            
            default:
                println("STEPSIC: Couldn't parse step type.")
        }
        
        timerDoneLabel.setHidden(true)
    
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Kick off the animation, but only if we haven't seen it yet:
        if !alreadySeen {
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: 0, length: animationLength),
                duration: 1,
                repeatCount: 1)
            alreadySeen = true
        }
        
        // Show the label afterward:
        setTimerForFunction("showLabel", seconds: 0.5)

    }
    
    
    // ** TO-DO **
    // Create methods that handle different ways of displaying the Step's info. Such as: changing celsius to fahrenheit with a tap (temperatureInFahrenheit = (celsius! * 1.8) + 32.0), or calculating how high to fill the Aeropress (displayed using the Aeropress notches).
    
    
    func showLabel() {
        timerDoneLabel.setHidden(false)
    }
    
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }

    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
