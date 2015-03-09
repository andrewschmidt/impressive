//
//  Step.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation

public class Step: NSObject {
    
    public let type: StepType
    public let timer: Int?
    public let measurement: Int?
    public let temperatureInFahrenheit: Double?
    public let temperatureInCelsius: Double?
    
    
    public init(_ type: StepType, howLong timer: Int?) {
        self.type = type
        self.timer = timer
    }
    
    
    init(_ type: StepType, howMuch measurement: Int?) {
        self.type = type
        self.measurement = measurement
    }
    
    
    init(_ type: StepType, howHotFahrenheit fahrenheit: Double?) {
        self.type = type
        self.temperatureInFahrenheit = fahrenheit
        self.temperatureInCelsius = (fahrenheit! - 32.0) / 1.8
    }
    
    
    init(_ type: StepType, howHotCelsius celsius: Double?) {
        self.type = type
        self.temperatureInCelsius = celsius
        self.temperatureInFahrenheit = (celsius! * 1.8) + 32.0
    }
    
    
    func convertToNSDict() -> NSDictionary {
        var stepAsDict = [NSString: AnyObject]()
        
        switch self.type {
        case .Heat:
            stepAsDict["type"] = "Heat"
        case .Pour:
            stepAsDict["type"] = "Pour"
        case .Stir:
            stepAsDict["type"] = "Stir"
        case .Press:
            stepAsDict["type"] = "Press"
        default:
            println("Step.convertToDict(): Error identifying step type.")
        }
        
        if let checkTimer = self.timer {
            stepAsDict["howLong"] = self.timer
        }
        if let checkMeasurement = self.measurement {
            stepAsDict["howMuch"] = self.measurement
        }
        if let checkTemperatureInCelsius = self.temperatureInCelsius {
            stepAsDict["howHotCelsius"] = self.temperatureInCelsius as Double!
        }

        return stepAsDict as NSDictionary
    }
    
}


public enum StepType {
    case Heat
    case Pour
    case Stir
    case Press
}