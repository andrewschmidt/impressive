//
//  HeatStepController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 5/13/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class HeatStepController: WKInterfaceController {
    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var typeLabel: WKInterfaceLabel!
    @IBOutlet weak var temperatureButton: WKInterfaceButton!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var scaleLabel: WKInterfaceLabel!
    
    var alreadySeen = false
    var animationLength: Int!
    var step: Step!
    
    var temperature: Double!
    var scale: String!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("HEATSTEPCONTROLLER: awakeWithContext called.")
        step = context as! Step
        
        typeLabel.setText(step.type)
        
        stepGroup.setBackgroundImageNamed("TSwiftKarate")
        animationLength = 7
        
        temperatureButton.setHidden(true)
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        if !alreadySeen {
            alreadySeen = true
            println("HEATSTEPCONTROLLER: First time seeing.")
            
            temperatureButton.setHidden(true)

            // Kick off the animation, but only if we haven't seen it yet:
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: 0, length: animationLength),
                duration: 1,
                repeatCount: 1)
            
            // Get ready to show whichever UI element:
            setTimerForFunction("showTemperature", seconds: 2)
            
        } else {
            // Set the animation to the last frame (where it should have cleared the screen):
            println("HEATSTEPCONTROLLER: Already seen.")
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: animationLength-1, length: 1),
                duration: 1,
                repeatCount: 1)
                        
            // Immediately show whichever UI element:
            showTemperature()
        }
        
    }
    
    override func didDeactivate() {
        // Below are commands that need to be wrapped in some sort of heuristics detection - a timer to determine whether the screen's being looked at by a user or by the system.
        println("HEATSTEPCONTROLLER: DidDeactivate called.")
        alreadySeen = false
        temperatureButton.setHidden(true) // Doesn't appear to work here.

        super.didDeactivate()
    }
    
    
    // TEMPERATURE LOGIC:
    
    func showTemperature() {
        temperature = step.value
        temperatureLabel.setText(temperatureFromDouble(temperature))
        
        scale = "Celsius"
        scaleLabel.setText(scale)
        
        temperatureButton.setHidden(false)
    }
    
    @IBAction func temperatureButtonPressed() {
        // Alternate between Celsius and Fahrenheit.
        if scale == "Celsius" {
            temperature = ((temperature * 1.8) + 32.0)
            scale = "Fahrenheit"
            
        } else {
            temperature = ((temperature - 32.0) / 1.8)
            scale = "Celsius"
            
        }
        
        scaleLabel.setText(scale)
        temperatureLabel.setText(temperatureFromDouble(temperature))
    }
    
    func temperatureFromDouble(value: Double) -> String {
        // Convert the value to a string with a ° on the end.
        let temperature = String(format: "%.f", value) + "°"
        return temperature
    }
    
    
    // MISC
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }
    
}
