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
    
    func convertToArray() -> [[String: Any]] {
        var recipeAsArray = [[String: Any]]()
        var stepsAsArray = [[String: Any]]()
        
        recipeAsArray.append(["name": self.name])
        
        for step in self.steps {
            stepsAsArray.append(step.convertToDict())
        }
        recipeAsArray.append(["steps": stepsAsArray])
        
        return recipeAsArray
    }
}


func loadPlist() -> NSArray {
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0)as NSString
    let path = documentsDirectory.stringByAppendingPathComponent("SavedRecipes.plist")
    
    let fileManager = NSFileManager.defaultManager()
    println(path)
    // Check if file exists
    if(!fileManager.fileExistsAtPath(path))
    {
        // If it doesn't, copy it from the default file in the Resources folder
        let bundle = NSBundle.mainBundle().pathForResource("DefaultRecipes", ofType: "plist")
        println("The bundle is at \(bundle)")
        fileManager.copyItemAtPath(bundle!, toPath: path, error:nil)
    }
    var data = NSArray(contentsOfFile: path)
    
    return data!
}

//func objectToDictionary(object: Any) {
//    
//    let objectMirror = reflect(object)
//    var objectAsDict: [String: Any]!
//    
//    println(objectMirror.count)
//    
//    for index in 0 ..< objectMirror.count {
//        let (name, propertyMirror) = objectMirror[index]
//        
//        var value = propertyMirror.value
//        
//        if value is NSArray {
//            println("Array Inception, on the property named \(name).")
//            var valueAsArray = value as NSArray
//            var valueAsArrayConverted: [Any]!
//            
//            println("Number of items in the Array? \(valueAsArray.count)")
//            
//            for index in 0 ..< valueAsArray.count {
//                println("Now we're iterating through each item in the array, checking if it's an object")
//                if valueAsArray[index] is AnyClass {
//                    valueAsArrayConverted.append(objectToDictionary(valueAsArray[index]))
//                }
//            }
//            
//            value = valueAsArrayConverted
//        }
//        else {
//            value = propertyMirror.value
//        }
//        
//        println("\(index): \(name) = \(value)")
//        
//        //objectAsDict[name] = value
//    }
//}