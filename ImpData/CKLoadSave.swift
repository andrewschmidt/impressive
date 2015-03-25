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
    
    
    let container = CKContainer.defaultContainer()
    
    
    public func saveRecipes(recipes: [Recipe], toPublicDatabase publicOrNot: Bool) {
        for recipe in recipes {
            saveRecipe(recipe, toPublicDatabase: publicOrNot)
        }
    }
    
    
    public func saveRecipe(recipe: Recipe, toPublicDatabase publicOrNot: Bool) {
        
        // We can convert steps to NSDicts, but unfortunately we can't upload NSDicts. So let's break all of the recipe's steps down into two simple arrays - one of step types, and one of step values.
        
        // Here are our arrays:
        var stepTypes = [String]()
        var stepValues = [Double]()
        
        // Now let's populate them:
        for step in recipe.steps {
            
            let stepAsDict = step.convertToNSDict() // This has the nice side effect of turning step types into Strings.
            
            stepTypes.append(stepAsDict["type"] as String)
            
            // Step types can be many different things. I've used a switch statement before, but this is faster:
            for key in stepAsDict.allKeys {
                if key as String != "type" && key as String != "name" { // Gotta ignore the step type, because we've already handled that.
                    let value: AnyObject? = stepAsDict[key as String]
                    stepValues.append(value as Double)
                }
            }
        }
        
        println("CKLOADSAVE: \(recipe.name)'s steps broken down into two arrays:")
        println(stepTypes)
        println(stepValues)
        
        // Next, let's create a new CKRecord to store our recipe.
        let recipeRecord = CKRecord(recordType: "Recipe")
        
        // Now let's write to it:
        recipeRecord.setObject(recipe.name, forKey: "name")
        recipeRecord.setObject(stepTypes, forKey: "stepTypes")
        recipeRecord.setObject(stepValues, forKey: "stepValues")
        
        // Now we save it!
        saveCKRecord(recipeRecord, toPublicDatabase: publicOrNot)
        
    }
    
    
    func saveCKRecord(record: CKRecord, toPublicDatabase: Bool) {
        
        let privateDatabase = container.privateCloudDatabase
        let publicDatabase = container.publicCloudDatabase
        
        println("CKLOADSAVE: The CKRecord we're trying to save is: ")
        println(record)
        
        privateDatabase.saveRecord(record, completionHandler:
            ({returnRecord, error in
                if let err = error {
                    
                    // Operation failed:
                    println("CKLOADSAVE: Failed to save recipe to private database!")
                    println(err)
                    
                    self.retrySaveCKRecord(record, toPublicDatabase: toPublicDatabase)
                    
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
    
    
    func retrySaveCKRecord(record: CKRecord, toPublicDatabase: Bool) {
        // This appears to work, but lordy does it look ugly in the NSLog. We're bumping up against the rate limit constantly!
        
        // Maybe a better approach would be passing failed CKRecords back to the method that asked to save them, having those methods add the CKRecords to an array of "recordsToTryAgain," or whatever, and then somehow have this method pick away at them...
        
        println("CLOUDSAVE: Retrying failed save.")
        var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector(saveCKRecord(record, toPublicDatabase: toPublicDatabase)), userInfo: nil, repeats: false)
    }
    
    
    public func checkCKStatus() {
        container.accountStatusWithCompletionHandler{
            [weak self] (status: CKAccountStatus, error: NSError!) in
            
            /* Be careful, we might be on a different thread now so make sure that
            your UI operations go on the main thread */
            dispatch_async(dispatch_get_main_queue(), {
                
                var title: String
                var message: String
                
                if error != nil{
                    
                    title = "CKLOADSAVE: Error - "
                    message = "An error occurred: \(error)."
                    
                } else {
                    
                    title = "CKLOADSAVE: No errors occurred - "
                    
                    switch status{
                        
                    case .Available:
                        message = "the user is logged in to iCloud."
                        
                    case .CouldNotDetermine:
                        message = "could not determine if the user is logged in to iCloud or not."
                        
                    case .NoAccount:
                        message = "user is not logged into iCloud."
                        
                    case .Restricted:
                        message = "could not access user's iCloud account information."
                        
                    }
                    println(title + message)
                }
                
            })
        }
    }
    
}
