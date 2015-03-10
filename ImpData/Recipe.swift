//
//  Recipe.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation

public class Recipe: NSObject {
    
    public var name: String
    public var steps: [Step]
    
    
    public init(name: String, steps: [Step]) {
        self.name = name
        self.steps = steps
    }
    
    
    func convertToNSDictionary() -> NSDictionary {
        
        var recipeAsDictionary = [NSString: AnyObject]()
        var stepsAsArray = [NSDictionary]()
        
        recipeAsDictionary["name"] = self.name
        
        for step in self.steps {
            stepsAsArray.append(step.convertToNSDict())
        }
        recipeAsDictionary["steps"] = stepsAsArray
        
        return recipeAsDictionary as NSDictionary
    }
}