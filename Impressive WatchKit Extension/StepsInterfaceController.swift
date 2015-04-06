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

    // Interface Controller variables:
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var actionLabel: WKInterfaceLabel!
    var alreadySeen = false
    var animationLength = 3
    var step: Step!
    
    // Timer button variables:
    @IBOutlet weak var timerButton: WKInterfaceButton!
    @IBOutlet weak var timer: WKInterfaceTimer!
    @IBOutlet weak var startstopLabel: WKInterfaceLabel!
    var countdown: NSDate!
    var startingTime: Double!
    var timerRunning: Bool!

    // Temperature button variables:
    @IBOutlet weak var temperatureButton: WKInterfaceButton!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    @IBOutlet weak var scaleLabel: WKInterfaceLabel!
    var temperature: Double!
    var scale: String!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        step = context as Step
        
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
        
        timerButton.setHidden(true)
        temperatureButton.setHidden(true)
    
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        timerButton.setHidden(true)
        temperatureButton.setHidden(true)
        
        // We set up the screen differently depending on whether the user's seen it or not yet. Sounds great on paper, but it's a bit clunky because the Watch takes a second to update. Might be worth just showing the whole animation over again...
        
        if !alreadySeen {
            alreadySeen = true
            
            // Kick off the animation, but only if we haven't seen it yet:
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: 0, length: animationLength),
                duration: 1,
                repeatCount: 1)
            
            // Get ready to show whichever UI element:
            setTimerForFunction("showTimer", seconds: 2)
            
        } else {
            // Set the animation to the last frame (where it should have cleared the screen):
            stepGroup.startAnimatingWithImagesInRange(
                NSRange(location: animationLength-1, length: 1),
                duration: 1,
                repeatCount: 1)
            
            // Immediately show whichever UI element:
            showTimer()
        }
        
    }
    
    
    // ** MARK **
    // Below is the logic for the different possible buttons that could appear depending on the step's type.
    
    // To-Do: Create methods that handle different ways of displaying the Step's info. Such as: changing celsius to fahrenheit with a tap (temperatureInFahrenheit = (celsius! * 1.8) + 32.0), or calculating how high to fill the Aeropress (displayed using the Aeropress notches).
    
    
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
    
    
    // TIMER LOGIC:
    func showTimer() {
        startingTime = step.value
        countdown = secondsFromDouble(startingTime)
        
        startstopLabel.setText("Tap to start")
        timer.setDate(countdown)
        
        timerRunning = false
        timerButton.setHidden(false)
    }
    
    @IBAction func timerButtonPressed() {
        // Start and stop the timer.
        
        if !timerRunning {
            // Set the starting values:
            countdown = secondsFromDouble(startingTime)
            timer.setDate(countdown)
            
            // Set the start/stop label text:
            startstopLabel.setText("Tap to pause")
            
            // And start it:
            timer.start()
            timerRunning = true
        
        } else {
            // Set the current time remaining as the new starting value:
            let timeRemaining = NSDate().timeIntervalSinceDate(countdown)
            
            // This confusing bit of code makes it so if the timer has finished counting down and a user taps it, it resets the timer to the full step value.
            if timeRemaining < 0.0 {
                startingTime = -timeRemaining
            } else {
                startingTime = step.value
                countdown = secondsFromDouble(startingTime)
                timer.setDate(countdown)
            }
            
            // Set the start/stop label:
            startstopLabel.setText("Tap to start")
            
            // And stop it:
            timer.stop()
            timerRunning = false
            
        }
    }
    
    func secondsFromDouble(value: Double) -> NSDate {
        var now = NSDate()
        var seconds: NSDate = now.dateByAddingTimeInterval(NSTimeInterval(value))
        return seconds
    }
    
    
// ** END **
    
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }

    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
