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

    @IBOutlet weak var actionLabel: WKInterfaceLabel!
    
    @IBOutlet weak var timerDoneLabel: WKInterfaceLabel!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        var currentStep = context as Step
        
        switch currentStep.type {
        
        case .Heat:
            actionLabel.setText("Heat")
        
        case .Pour:
            actionLabel.setText("Pour")
        
        case .Stir:
            actionLabel.setText("Stir")
        
        case .Press:
            actionLabel.setText("Press")
        
        }
        
        timerDoneLabel.setHidden(true)
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Let's test out our simple timer function.
        setTimerForFunction("showLabel", seconds: 1)
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
