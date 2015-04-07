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
    
    
    public func fetchDaily() {
        // get the newest Daily record
        // check if the record's creation date matches today's date
        
        // if so:
        // get the recipe record referenced by the daily record,
        // convert it into a Recipe,
        // send it back to the function caller.
        
        // if not:
        // get the recipe record referenced by the daily record,
        // get the creation date of that recipe record,
        // query for public recipe records created after that date - we need the next 1 chronologically
        // create a daily record referencing that recipe record
        // retry fetchDaily()
    }
    
    
    public func testDaily() {
        
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [sort]
        
        // Now that we've built the query, let's fetch those recipes!
        fetchRecords(query, fromDatabase: "public") {
            records in
            println("CKLOADSAVE: Attempting to save the first public recipe (sorted by date) in a daily record.")
            self.saveDaily(records[1] as CKRecord)
            
        }

    }
    
    
    func saveDaily(recipeRecord: CKRecord) {
        // Create a "Daily" record with a reference to the chosen "Recipe" record.
        
        // First, let's create our record:
        let daily = CKRecord(recordType: "Daily")
        
        // Next create the reference object.
        // Setting the action to "DeleteSelf" means if the recipe record is deleted, the daily record that references it will also be deleted.
        let referencedRecipe = CKReference(record: recipeRecord, action: CKReferenceAction.DeleteSelf)
        
        // Now add the reference object to the daily record:
        daily.setObject(referencedRecipe, forKey: "recipe")
        
        // We'd also like the Daily record to show the recipe name, author & brewer, for my sake:
        let recipe = createRecipeFromRecord(recipeRecord)
        
        daily.setObject(recipe.name, forKey: "name")
        daily.setObject(recipe.author, forKey: "author")
        daily.setObject(recipe.brewer, forKey: "brewer")
        
        // And finally save the daily record to the public database:
        saveRecord(daily, toDatabase: "public")
    }
    
    
    public func fetchPersonalRecipes(completion: (returnRecipes: [Recipe]) -> Void) { //It'd be interesting to give this function several optional parameters, and rename it "fetchRecipes." It could fetch an array of recipes matching whichever of the optional parameters you chose to pass it (name, newest, author, etc.)
        
        var personalRecipes = [Recipe]()
        
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        
        let query = CKQuery(recordType: "Recipe", predicate: predicate)
        query.sortDescriptors = [sort]
        
        // Now that we've built the query, let's fetch those recipes!
        fetchRecords(query, fromDatabase: "private") {
            records in
            
            for record in records {
                let recipe: Recipe? = self.createRecipeFromRecord(record as CKRecord)
                if recipe != nil {
                    personalRecipes.append(recipe!)
                }
            }
            
            completion(returnRecipes: personalRecipes)
        }
    }
    
    
    func fetchRecords(query: CKQuery, fromDatabase database: String, completion: (returnRecords: [CKRecord]) -> Void) {
        
        // First let's create a place to store our records:
        var records = [CKRecord]()
        
        // We need to interpret the right CKDatabase based on the string sent:
        var databaseToQuery: CKDatabase!

        switch database {
            case "public":
                databaseToQuery = publicDatabase
            
            case "private":
                databaseToQuery = privateDatabase
            
            default:
                println("CKLOADSAVE: Database '\(database)' not found. Defaulting to 'Public'.\r")
                databaseToQuery = publicDatabase
        }
        
        // Now let's query the selected database:
        databaseToQuery.performQuery(query, inZoneWithID: nil) {
            results, error in
            
            if error != nil {
                println("CKLOADSAVE: Error fetching records from the \(database) database. The error is:")
                println(error)
                println("\r")
                self.retryFetchRecords(query, fromDatabase: database) {
                    records in
                    completion(returnRecords: records as [CKRecord])
                }
                
            } else {
                
                for record in results {
                    records.append(record as CKRecord)
                }
                
                // And finally, send the data back to the completion block:
                completion(returnRecords: records)
            }
        }
    }
    
    
    // Here's a TOTALLY UNTESTED retry method:
    func retryFetchRecords(query: CKQuery, fromDatabase database: String, completion: (returnRecords: [CKRecord]) -> Void) {
        
        println("CLOUDSAVE: Retrying failed fetch.\r")
        
        dispatch_sync(queue) { // Should I introduce a time delay here?
            self.fetchRecords(query, fromDatabase: database) {
                records in
                completion(returnRecords: records as [CKRecord])
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
        
//        println("CKLOADSAVE: \(recipe.name)'s steps broken down into two arrays:")
//        println(stepTypes)
//        println(stepValues)
//        println("\r")
        
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
            self.saveRecord(recipeRecord, toDatabase: database)
        }
        
    }
    
    
    func createRecipeFromRecord(record: CKRecord) -> Recipe {
        
        // This CANNOT be the right way to protect against nil values. But let's do it for now:
        var name: String
        var author: String
        var brewer: String
        
        // If any of these keys don't exist or return nil, let's fill in the default values:
        if let checkName = record.objectForKey("name") as? String {
            name = checkName
        } else {
            name = ""
        }
        
        if let checkAuthor = record.objectForKey("author") as? String {
            author = checkAuthor
        } else {
            author = ""
        }
        
        if let checkBrewer = record.objectForKey("brewer") as? String {
            brewer = checkBrewer
        } else {
            brewer = "AeroPress"
        }
        
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
    
    
    func saveRecord(record: CKRecord, toDatabase database: String) {
        
        println("CKLOADSAVE: The CKRecord we're trying to save is: ")
        println(record)
        println("\r")
        
        switch database {
            case "public":
                publicDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if let err = error {
                        // Operation failed:
                        println("CKLOADSAVE: Failed to save record to public database.")
                        println(err)
                        println("\r")
                        
                    } else {
                        // Operation succeeded:
                        println("CKLOADSAVE: Saved record to public database.\r")

                    }
            }
            
            case "private":
                privateDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if error != nil {
                        // Operation failed:
                        println("CKLOADSAVE: Failed to save record to private database.")
                        println(error)
                        println("\r")

                        self.retrySaveRecord(record, toDatabase: database)
                        
                    } else {
                        // Operation succeeded:
                        println("CKLOADSAVE: Saved record to private database.\r")
                        
                    }
            }
            
            default:
                println("CKLOADSAVE: No database specified for save operation.\r")
        }
    }
    
    
    func retrySaveRecord(record: CKRecord, toDatabase database: String) {
        
        println("CLOUDSAVE: Retrying failed save.\r")
        dispatch_sync(queue) {
            self.saveRecord(record, toDatabase: database) // Should I introduce a time delay here?
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
                    println(title + message + "\r")

                }
                
            })
        }
    }
    
}
