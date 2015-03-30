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
    public var author: String
    public var brewer: String
    public var steps: [Step]
    
    
    init(_ name: String, by author: String, using brewer: String, steps: [Step]) {
        self.name = name
        self.author = author
        self.brewer = brewer
        self.steps = steps
    }
    
    
    init(fromDictionary dictionary: NSDictionary) {
        
        var stepsArray = [Step]()
        
//        var stepTypes = dictionary["stepTypes"] as [String] // Do I want to do this?
//        var stepValues = dictionary["stepValues"] as [Double] // Muddy up the code to make file structures match between the cloud and locally?
//        
//        for (i, type) in enumerate(stepTypes) {
//            let step = Step(type, value: stepValues[i])
//            stepsArray.append(step)
//        }
        
        for stepAsNSDict in dictionary["steps"] as NSArray {
            let step = Step(fromDictionary: stepAsNSDict as NSDictionary)
            stepsArray.append(step)
        }
        
        self.name = dictionary["name"] as String
        self.author = dictionary["author"] as String
        self.brewer = dictionary["brewer"] as String
        self.steps = stepsArray
    }
    
    
    func convertToNSDictionary() -> NSDictionary {
        
//        var stepTypes = [String]()
//        var stepValues = [Double]()
//        
//        for step in self.steps {
//            stepTypes.append(step.type)
//            stepValues.append(step.value)
//        }
        
        var stepsAsArray = [NSDictionary]()
        
        for step in self.steps {
            stepsAsArray.append(step.convertToNSDict())
        }
        
        var recipeAsDictionary = [NSString: AnyObject]()
        
        recipeAsDictionary["name"] = self.name
        recipeAsDictionary["author"] = self.author
        recipeAsDictionary["steps"] = stepsAsArray
//        recipeAsDictionary["stepTypes"] = stepTypes // **LOSE IF DESIRED, see above**
//        recipeAsDictionary["stepValues"] = stepValues // **LOSE IF DESIRED**
        
        return recipeAsDictionary as NSDictionary
    }
    
}