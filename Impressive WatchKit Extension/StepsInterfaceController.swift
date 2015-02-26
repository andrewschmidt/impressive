//
//  RecipeStepsInterfaceController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation


class StepsInterfaceController: WKInterfaceController {


    @IBOutlet weak var actionLabel: WKInterfaceLabel!
    
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
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
