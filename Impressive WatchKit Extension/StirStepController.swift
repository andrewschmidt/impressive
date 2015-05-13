//
//  StirStepController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 5/13/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class StirStepController: WKInterfaceController {
    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var typeLabel: WKInterfaceLabel!
    @IBOutlet weak var timerButton: WKInterfaceButton!
    @IBOutlet weak var timer: WKInterfaceTimer!
    @IBOutlet weak var startstopLabel: WKInterfaceLabel!
    
    var alreadySeen = false
    var animationLength = 3
    var step: Step!
    
    var countdown: NSDate!
    var startingTime: Double!
    var timerRunning: Bool!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        step = context as! Step
        
        typeLabel.setText(step.type)
        
        stepGroup.setBackgroundImageNamed("TSwiftKarate") // Eventually this should also use step.type - or simply reference an image baked into the storyboard?
        animationLength = 20
        
        timerButton.setHidden(true)
    }
    
    
    override func willActivate() {
        super.willActivate()
        
//        timerButton.setHidden(true) // Crashing with this, I think...
        
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
//            showTimer() // Crashing with this, I think...
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // To-Do: Create methods to handle calculating how high to fill the Aeropress, alternating between liquid measurement and units of Aeropress notches.
    // For now I've left the timer logic here, for no particular reason.
    
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
    
    
    // MISC
    
    func setTimerForFunction(functionName: String, seconds: Double) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(Double(seconds), target: self, selector: Selector(functionName), userInfo: nil, repeats: false)
    }
    
}
