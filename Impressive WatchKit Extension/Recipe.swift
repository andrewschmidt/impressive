//
//  Recipe.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation

class Recipe: NSObject {
    var name: String
    var steps: [Step]
    
    init(name: String, steps: [Step]) {
        self.name = name
        self.steps = steps
    }
    
    func convertToNSArray() -> NSArray {
        
        // Need to change this to return recipes as a NSDictionary with two keys: "name" and "steps".
        var recipeAsArray = [[NSString: AnyObject]]()
        var stepsAsArray = [NSDictionary]()
        
        recipeAsArray.append(["name": self.name])
        
        for step in self.steps {
            stepsAsArray.append(step.convertToNSDict())
        }
        recipeAsArray.append(["steps": stepsAsArray])
        
        return recipeAsArray as NSArray
    }
}