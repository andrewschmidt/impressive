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
    var startStopTimer: NSTimer!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        step = context as! Step
        
        typeLabel.setText(step.type)
        showTimer()
        
//        stepGroup.setBackgroundImageNamed("TSwiftKarate") // Eventually this should also use step.type - or simply reference an image baked into the storyboard?
//        animationLength = 7
        
//        timerButton.setHidden(true)
    }
    
    
    override func willActivate() {
        super.willActivate()
        
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
            
            // Set same timer to change the label text when the countdown ends:
            startStopTimer = NSTimer.scheduledTimerWithTimeInterval(startingTime, target: self, selector: Selector("setLabelToReset"), userInfo: nil, repeats: false)

//            setTimerForFunction("setLabelToReset", seconds: startingTime)
            
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
            
            // Cancel the start/stop label's countdown to "Tap to reset":
            startStopTimer.invalidate()
            
            // And stop it:
            timer.stop()
            timerRunning = false
            
        }
    }
    
    func setLabelToReset() {
        startstopLabel.setText("Tap to reset")
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
