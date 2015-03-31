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
    
    
    var container: CKContainer
    var publicDatabase: CKDatabase
    var privateDatabase: CKDatabase
    
    // Let's make a custom dispatch queue, so we can avoid overloading iCloud.
    let queue = dispatch_queue_create(
        "com.AndrewSchmidt.Impressive.CKLoadSaveQueue", DISPATCH_QUEUE_SERIAL)
    
    
    override init() {
        // Here are some easier ways to access our CloudKit container & databases:
        container = CKContainer.defaultContainer()
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
        
        super.init()
        
        // And now would be a good time to make sure our user is actually logged in:
        checkCKStatus()
    }
    
    
    public func fetchPersonalRecipes(completion: (returnRecipes: [Recipe]) -> Void) { //It'd be interesting to give this function several optional parameters, and rename it "fetchRecipes." It could fetch an array of recipes matching whichever of the optional parameters you chose to pass it (name, newest, author, etc.)
        
        var personalRecipes = [Recipe]()
        
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [sort]
        
        privateDatabase.performQuery(query, inZoneWithID: nil) {
            results, error in
            
            if error != nil {
                println("CKLOADSAVE: Error fetching personal recipes:")
                println(error)
                
            } else {
                for record in results {
                    let recipe = self.createRecipeFromRecord(record as CKRecord)
                    personalRecipes.append(recipe)
                }
                
                // Now that we know we've got the data, let's send it back to the completion block!
                completion(returnRecipes: personalRecipes)
                
            }
        }
    }
    
    
    public func saveRecipes(recipes: [Recipe], toDatabase database: String) {
        for recipe in recipes {
            saveRecipe(recipe, toDatabase: database)
        }
    }
    
    
    public func saveRecipe(recipe: Recipe, toDatabase database: String) {
        
        // Unfortunately we can't upload NSDicts — which are what we use to store Steps client-side. 
        // Instead, let's break all of the recipe's steps down into two arrays - one of types, and one of values.
        
        // Here are our arrays:
        var stepTypes = [String]()
        var stepValues = [Double]()
        
        // Now let's populate them:
        for step in recipe.steps {
            stepTypes.append(step.type)
            stepValues.append(step.value)
        }
        
        println("CKLOADSAVE: \(recipe.name)'s steps broken down into two arrays:")
        println(stepTypes)
        println(stepValues)
        
        // Next, let's create a new CKRecord to store our recipe.
        let recipeRecord = CKRecord(recordType: "Recipe")
        
        // Now let's write to it:
        recipeRecord.setObject(recipe.name, forKey: "name")
        recipeRecord.setObject(recipe.author, forKey: "author")
        recipeRecord.setObject(recipe.brewer, forKey: "brewer")
        recipeRecord.setObject(stepTypes, forKey: "stepTypes")
        recipeRecord.setObject(stepValues, forKey: "stepValues")
        
        // Now we save it!
        dispatch_sync(queue) {
            self.saveCKRecord(recipeRecord, toDatabase: database)
        }
        
    }
    
    
    func createRecipeFromRecord(record: CKRecord) -> Recipe {
        
        // First the easy stuff:
        let name = record.objectForKey("name") as String
        let author = record.objectForKey("author") as String
        let brewer = record.objectForKey("brewer") as String
        
        // Next, turn corresponding types & values in two arrays into Step objects.
        let stepTypes = record.objectForKey("stepTypes") as [String]
        let stepValues = record.objectForKey("stepValues") as [Double]
        
        var steps = [Step]()
        
        var i = 0
        for i in 0 ..< stepTypes.count {
            let type = stepTypes[i] as String
            let value = stepValues[i] as Double
            let step = Step(type, value: value)
            steps.append(step)
        }
        
        let recipe = Recipe(name, by: author, using: brewer, steps: steps)
        return recipe
    }
    
    
    func saveCKRecord(record: CKRecord, toDatabase database: String) {
        
        println("CKLOADSAVE: The CKRecord we're trying to save is: ")
        println(record)
        
        switch database {
            case "public":
                publicDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if let err = error {
                        // Operation failed:
                        println("CKLOADSAVE: Failed to save recipe to public database.")
                        println(err)
                        
                    } else {
                        // Operation succeeded:
                        println("CKLOADSAVE: Saved recipe to public database.")
                        
                    }
            }
            
            case "private":
                privateDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if error != nil {
                        // Operation failed:
                        println("CKLOADSAVE: Failed to save recipe to private database.")
                        println(error)
                        
                        self.retrySaveCKRecord(record, toDatabase: database)
                        
                    } else {
                        // Operation succeeded:
                        println("CKLOADSAVE: Saved recipe to private database.")
                        
                    }
            }
            
            default:
                println("CKLOADSAVE: No database specified for save operation.")
        }
    }
    
    
    func retrySaveCKRecord(record: CKRecord, toDatabase database: String) {
        
        println("CLOUDSAVE: Retrying failed save.")
        dispatch_sync(queue) {
            self.saveCKRecord(record, toDatabase: database) // Should I introduce a time delay here?
        }
    }
    
    
    func checkCKStatus() {
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
