//
//  Step.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class Step: NSObject {
    let action: String
    let timer: Int?
    let measurement: Int?
    let temperatureInFahrenheit: Double?
    let temperatureInCelsius: Double?
    
    init(_ action: String, howLong timer: Int?) {
        self.action = action
        self.timer = timer
    }
    
    init(_ action: String, howMuch measurement: Int?) {
        self.action = action
        self.measurement = measurement
    }
    
    init(_ action: String, howHotFahrenheit fahrenheit: Double?) {
        self.action = action
        self.temperatureInFahrenheit = fahrenheit
        self.temperatureInCelsius = (fahrenheit! - 32.0) / 1.8
    }
    
    init(_ action: String, howHotCelsius celsius: Double?) {
        self.action = action
        self.temperatureInCelsius = celsius
        self.temperatureInFahrenheit = (celsius! * 1.8) + 32.0
    }
}