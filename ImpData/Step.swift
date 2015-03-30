//
//  Step.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation

public class Step: NSObject {
    
    public let type: String
    public let value: Double
    
    
    init(_ type: String, value: Double) {
        self.type = type
        self.value = value
    }
    
    
    init(fromDictionary dictionary: NSDictionary) {
        self.type = dictionary["type"] as String
        self.value = dictionary["value"] as Double
    }
    
    
    func convertToNSDict() -> NSDictionary {
        
        var stepAsDict = [NSString: AnyObject]()
        
        stepAsDict["type"] = self.type
        stepAsDict["value"] = self.value

        return stepAsDict as NSDictionary
    }
    
}