//
//  PourStepController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 5/13/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class PourStepController: WKInterfaceController {
    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var typeLabel: WKInterfaceLabel!

    @IBOutlet weak var measureButton: WKInterfaceButton!
    @IBOutlet weak var measureLabel: WKInterfaceLabel!
    @IBOutlet weak var unitLabel: WKInterfaceLabel!
    
    var alreadySeen = false
    var animationLength = 3
    var step: Step!
    
    var unit: String!
    var measurement: Double!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        step = context as! Step
        
        typeLabel.setText(step.type) // Moved from awakeWithContext, because it wasn't firing when revisiting the page.
        showMeasureButton()

//        stepGroup.setBackgroundImageNamed("Mushroom")
//        animationLength = 20
        
//        timerButton.setHidden(true)
    }
    
    
    override func willActivate() {
        super.willActivate()

        typeLabel.setText(step.type) // Moved from awakeWithContext, because it wasn't firing when revisiting the page.
        showMeasureButton()
        
//        if !alreadySeen {
//            alreadySeen = true
//            
//            // Kick off the animation, but only if we haven't seen it yet:
//            stepGroup.startAnimatingWithImagesInRange(
//                NSRange(location: 0, length: animationLength),
//                duration: 1,
//                repeatCount: 1)
//            
//            // Get ready to show whichever UI element:
//            setTimerForFunction("showTimer", seconds: 2)
//            
//        } else {
//            // Set the animation to the last frame (where it should have cleared the screen):
//            stepGroup.startAnimatingWithImagesInRange(
//                NSRange(location: animationLength-1, length: 1),
//                duration: 1,
//                repeatCount: 1)
//            
//            // Immediately show whichever UI element:
//            showTimer()
//        }
        
    }
    
    override func didDeactivate() {
        alreadySeen = false //Will this fix the new interface activation problems in Watch OS 1.0.1?

        super.didDeactivate()
    }
    
    
    // CONVERSION LOGIC
    
    func showMeasureButton() {
        unit = "Milliliter"
        measurement = step.value
        
        measureLabel.setText(stringFromDouble(measurement, format: "%.f"))
        measureButton.setHidden(false)
    }
    
    @IBAction func measureButtonPressed() {
        // Alternate between unit types.
        
        var format: String
        
        switch unit {

            case "Milliliter":
                unit = "AeroPress Notch"
                measurement = measurement/60.0
                format = "%.2f"
                
            case "AeroPress Notch":
                unit = "Milliliter"
                measurement = measurement*60.0
                format = "%.f"
                
            default:
                unit = "Milliliter"
                measurement = step.value
                format = "%.f"
        }
        
        unitLabel.setText(unit)
        measureLabel.setText(stringFromDouble(measurement, format: format))
    }
    
    
    // MISC
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }
    
    func stringFromDouble(value: Double, format: String) -> String {
        let str = String(format: format, value)
        return str
    }
    
}
