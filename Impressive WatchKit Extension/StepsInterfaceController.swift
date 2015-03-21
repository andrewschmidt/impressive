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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentStep = context as Step
        
        switch currentStep.type {
        
        case .Heat:
            actionLabel.setText("Heat")
            stepGroup.setBackgroundImageNamed("TSwiftKarate")
        
        case .Pour:
            actionLabel.setText("Pour")
            stepGroup.setBackgroundImageNamed("TSwiftKarate")
            
        case .Stir:
            actionLabel.setText("Stir")
            stepGroup.setBackgroundImageNamed("TSwiftKarate")
            
        case .Press:
            actionLabel.setText("Press")
            stepGroup.setBackgroundImageNamed("TSwiftKarate")
            
        }
        
        timerDoneLabel.setHidden(true)
    
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Kick off the animation, but only if we haven't seen it yet:
        if !alreadySeen {
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: 0, length: 7),
                duration: 1,
                repeatCount: 1)
            alreadySeen = true
        }
        
        // Show the label afterward:
        setTimerForFunction("showLabel", seconds: 0.5)

    }
    
    
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
