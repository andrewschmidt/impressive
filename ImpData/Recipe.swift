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
        
        for stepAsNSDict in dictionary["steps"] as! NSArray {
            let step = Step(fromDictionary: stepAsNSDict as! NSDictionary)
            stepsArray.append(step)
        }
        
        self.name = dictionary["name"] as! String
        self.author = dictionary["author"] as! String
        self.brewer = dictionary["brewer"] as! String
        self.steps = stepsArray
    }
    
    
    func convertToNSDictionary() -> NSDictionary {
        
        var stepsAsArray = [NSDictionary]()
        
        for step in self.steps {
            stepsAsArray.append(step.convertToNSDict())
        }
        
        var recipeAsDictionary = [NSString: AnyObject]()
        
        recipeAsDictionary["name"] = name
        recipeAsDictionary["author"] = author
        recipeAsDictionary["brewer"] = brewer
        recipeAsDictionary["steps"] = stepsAsArray
        
        return recipeAsDictionary as NSDictionary
    }
    
}