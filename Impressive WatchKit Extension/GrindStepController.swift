//
//  GrindStepController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 6/6/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import WatchKit
import Foundation
import ImpData


class GrindStepController: WKInterfaceController {
    
    @IBOutlet weak var stepGroup: WKInterfaceGroup!
    @IBOutlet weak var typeLabel: WKInterfaceLabel!
    
    @IBOutlet weak var measureButton: WKInterfaceButton!
    @IBOutlet weak var measureLabel: WKInterfaceLabel!
    @IBOutlet weak var unitLabel: WKInterfaceLabel!
    
    @IBOutlet weak var separator: WKInterfaceSeparator!
    
    @IBOutlet weak var miniTimerButton: WKInterfaceButton!
    @IBOutlet weak var miniTimerLabel: WKInterfaceLabel!
    
    @IBOutlet weak var timerButton: WKInterfaceButton!
    @IBOutlet weak var timer: WKInterfaceTimer!
    @IBOutlet weak var startstopLabel: WKInterfaceLabel!
    
//    var step: Step!
    var seconds: Double!
    
    var beanCount: Double!
    var unit: String!
    
    var countdown: NSDate!
    var startingTime: Double!
    var timerRunning: Bool!
    var startStopTimer: NSTimer!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
//        let checkStep: Step = context as! Step
//        println(checkStep.type)
        
        let contextArray: [Double] = context as! [Double]
        seconds = contextArray[0]
        beanCount = contextArray[1]
        
        typeLabel.setText("Grind")
        
        showMeasureButton()
        showMiniTimer()
        
        measureButton.setHidden(false)
        timerButton.setHidden(true)
        
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        typeLabel.setText("Grind")
        
        showMeasureButton()
        showMiniTimer()
        
        measureButton.setHidden(false)
        timerButton.setHidden(true)
        
    }
    
    override func didDeactivate() {
        
        super.didDeactivate()
    }
    
    
    // MEASURE LOGIC:
    
    func showMeasureButton() {
        unit = "grams"
        measureLabel.setText(stringFromDouble(beanCount, format: "%.f"))
        measureButton.setHidden(false)
    }
    
    @IBAction func measureButtonPressed() {
        // Alternate between unit types.
        
        var format: String
        
        if unit == "grams" {
            unit = "ounces"
            beanCount = beanCount*0.0353
            format = "%.1f"
        } else {
            unit = "grams"
            beanCount = beanCount*28.3495
            format = "%.f"
        }
        
        unitLabel.setText(unit)
        measureLabel.setText(stringFromDouble(beanCount, format: format))
    }
    
    
    // TIMER LOGIC:
    
    func showMiniTimer() {
        miniTimerLabel.setText(stringFromDouble(seconds, format: "%.f"))
        miniTimerButton.setHidden(false)
    }
    
    @IBAction func miniTimerButtonPressed() {
        measureButton.setHidden(true)
        separator.setHidden(true)
        miniTimerButton.setHidden(true)
        showTimer()
    }
    
    func showTimer() {
        startingTime = seconds + 1.0
        countdown = secondsFromDouble(startingTime)
        
        startstopLabel.setText("Tap to pause")
        timer.setDate(countdown)
        
        // Start it immediately:
        timer.start()
        timerRunning = true
        
        // Set same timer to change the label text when the countdown ends:
        startStopTimer = NSTimer.scheduledTimerWithTimeInterval(startingTime, target: self, selector: Selector("setLabelToReset"), userInfo: nil, repeats: false)
        
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
                startingTime = seconds
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
    
    func stringFromDouble(value: Double, format: String) -> String {
        let str = String(format: format, value)
        return str
    }
}
