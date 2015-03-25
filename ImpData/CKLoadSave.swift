//
//  CKLoadSave.swift
//  Impressive
//
//  Created by Andrew Schmidt on 3/24/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import CloudKit

public class CKLoadSave: NSObject {
    
    // Set this thing up as a singleton, so it's not all in the global space.
    // Accessible via CKLoadSave.sharedInstance.
    
    public class var sharedInstance: CKLoadSave {
        struct Singleton {
            static let instance = CKLoadSave()
        }
        return Singleton.instance
    }
    
    
    public func saveRecipe(recipe: Recipe, toPublicDatabase: Bool) {

        // First, convert the recipe object to a more manageable NSDictionary.
        // This also converts the steps to NSDicts inside an array.
        let recipeAsNSDict = recipe.convertToNSDictionary()
        
        // We can't upload an NSDict. So let's convert each of the steps into two arrays: keys and values.
        // We'll store all the recipes steps (as arrays) in this big array:
        var stepsAsArrays = [[AnyObject]]()
        
        for step in recipe.steps {
            
            let stepAsDict = step.convertToNSDict()
            
            let stepKeys: [AnyObject] = stepAsDict.allKeys
            var stepValues = [AnyObject]()
            
            for key in stepKeys {
                let value: AnyObject? = stepAsDict[key as String]
                stepValues.append(value!)
            }
            
            let stepAsArrays = [stepKeys, stepValues]
            stepsAsArrays.append(stepAsArrays)
        }
        
        // Next, create a new CKRecord to store our recipe.
        let recipeRecord = CKRecord(recordType: "Recipe")
        
        // Now we write to it. First the easy stuff:
        recipeRecord.setObject(recipeAsNSDict["name"] as String, forKey: "name")
        
        // Then we write the steps as an array of arrays:
        recipeRecord.setObject(stepsAsArrays, forKey: "steps")
        
        // Now we save it!
        saveCKRecord(recipeRecord, toPublicDatabase: toPublicDatabase)
        
    }
    
    
    func saveCKRecord(record: CKRecord, toPublicDatabase: Bool) {
        
        let container = CKContainer.defaultContainer()
        let privateDatabase = container.privateCloudDatabase
        let publicDatabase = container.publicCloudDatabase
        
        privateDatabase.saveRecord(record, completionHandler:
            ({returnRecord, error in
                if let err = error {
                    // Operation failed:
                    println("CKLOADSAVE: Failed to save recipe to private database!")
                    println(err)
                } else {
                    // Operation succeeded:
                    println("CKLOADSAVE: Saved recipe to private database!")
                }
            }))
        
        // And if requested, we also save it to the public database:
        if toPublicDatabase {
            publicDatabase.saveRecord(record, completionHandler:
                ({returnRecord, error in
                    if let err = error {
                        // Operation failed:
                        println("CKLOADSAVE: Failed to save recipe to public database!")
                        println(err)
                    } else {
                        // Operation succeeded:
                        println("CKLOADSAVE: Saved recipe to public database!")
                    }
                }))
        }
    }
    
    
}
