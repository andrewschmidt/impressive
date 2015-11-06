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
    
    
    public func fetchDaily(completion: (dailyRecipe: Recipe) -> Void) {
        // TO ADD: A "loadDailyRecipe()" function in LoadSave. It'd do this:
        // 1. Check if the saved daily recipe is new enough. Use it, if so.
        // 2. If not, check if there's a daily recipe saved for tomorrow - possibly downloaded via subscription.
        // 3. If not, run fetchDaily().
        
        print("\rCKLOADSAVE: Attempting to fetch the Daily record for today...")
        
        // First we need a time range covering the entire day:
        let calendar = NSCalendar.currentCalendar() // or = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let today = NSDate()
        let startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: today, options: NSCalendarOptions(0))!
        let endDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: today, options: NSCalendarOptions(0))!
        
//        println("CKLOADSAVE: today is:", today)
//        println("CKLOADSAVE: fetchDaily's startDate is: ", startDate)
//        println("CKLOADSAVE: fetchDaily's endDate is: ", endDate)
        
        // Next we build a predicate for that date range and query with it:
        let todayPredicate = NSPredicate(format: "(creationDate > %@) AND (creationDate < %@)", startDate, endDate)
        let query = CKQuery(recordType: "Daily", predicate: todayPredicate)
        
        // Now let's run the query, and see if we get anything back.
        fetchRecords(query, fromDatabase: "public") {
            records in
            
            if records.count != 0 {
                
                print("CKLOADSAVE: Found a Daily record. Getting the recipe it references...")
                
                // Get the recipe record referenced by the daily record...
                let dailyRecord = records[0]
                let dailyReference = dailyRecord.objectForKey("recipe") as! CKReference
                let dailyRecipeID = dailyReference.recordID
                
                self.fetchRecordForID(dailyRecipeID, recordType: "Recipe", database: "public") { //There's a built-in version of this, fetchRecordWithID.
                    dailyRecipeRecord in
                    
                    // Convert the referenced Recipe record into a Recipe object:
                    let dailyRecipe = self.createRecipeFromRecord(dailyRecipeRecord)
                    
                    print("CKLOADSAVE: Here's the daily recipe!")
                    print(dailyRecipe)
                    
                    // And return it to the function caller:
                    completion(dailyRecipe: dailyRecipe)
                }
                
            } else {
                
                print("\rCKLOADSAVE: No Daily records returned. Time to make our own!")
                print("\r********************************")
                print("\rCKLOADSAVE: Getting the previous Daily record...")
                
                // Get the previous daily record.
                let previousDailiesPredicate = NSPredicate(format: "creationDate < %@", startDate)
                let sort = NSSortDescriptor(key: "creationDate", ascending: false) //This means "newest to oldest."
                let query = CKQuery(recordType: "Daily", predicate: previousDailiesPredicate)
                query.sortDescriptors = [sort]
                
                self.fetchRecords(query, fromDatabase: "public") {
                    previousDailyRecords in
                    
                    if previousDailyRecords.count != 0 {
                        
                        print("CKLOADSAVE: Successfully fetched the previous Daily record. This was it:")
                        print(previousDailyRecords[0])
                        print("\rCKLOADSAVE: Now getting the Recipe record it references...")
                        
                        // Now we need to get the Recipe record referenced by that previous Daily record.
                        let previousDailyRecord = previousDailyRecords[0]
                        let previousDailyReference = previousDailyRecord.objectForKey("recipe") as! CKReference
                        let previousDailyRecipeID = previousDailyReference.recordID
                        
                        self.fetchRecordForID(previousDailyRecipeID, recordType: "Recipe", database: "public") {
                            previousDailyRecipeRecord in
                            
                            print("CKLOADSAVE: Successfully got the previous daily Recipe record. Here it is:")
                            print(previousDailyRecipeRecord)
                            print("\rCKLOADSAVE: Now querying for the next Recipe record, chronologically.")
                            
                            // We need the creation date of that previous Recipe record...
                            let previousCreationDate = previousDailyRecipeRecord.objectForKey("creationDate") as! NSDate
                            
                            // So we can query for the next Recipe record, chronologically:
                            let newerThan = NSPredicate(format: "creationDate > %@", previousCreationDate)
                            let oldestToNewest = NSSortDescriptor(key: "creationDate", ascending: true)
                            let query = CKQuery(recordType: "Recipe", predicate: newerThan)
                            query.sortDescriptors = [oldestToNewest]
                            
                            self.fetchRecords(query, fromDatabase: "public") {
                                nextRecipeRecords in
                                
                                if nextRecipeRecords.count != 0 {
                                    
                                    let nextRecipeRecord = nextRecipeRecords[0]
                                    
                                    print("CKLOADSAVE: The next Recipe record, chronologically, is:")
                                    print(nextRecipeRecord)
                                    print("\r")
                                    print("CKLOADSAVE: Time to save that as the new Daily recipe, and retry the fetch. \r")
                                    
                                    
                                    // And make a Daily record that points to that next Recipe record:
                                    self.saveDaily(nextRecipeRecord){
                                        success in
                                        if success == true {
                                            self.retryFetchDaily(){recipe in completion(dailyRecipe: recipe)}
                                        }
                                    }
                                    
                                } else {
                                    // The rare occurence when there are no newer Recipe records.
                                    // Reset the loop back to the oldest Recipe record.
                                    
                                    print("CKLOADSAVE: There aren't any newer recipes to use for the pick of the day!")
                                    print("CKLOADSAVE: Querying for the oldest recipe...")
                                    
                                    let allRecords = NSPredicate(value: true)
                                    let oldestToNewest = NSSortDescriptor(key: "creationDate", ascending: true)
                                    let query = CKQuery(recordType: "Recipe", predicate: allRecords)
                                    query.sortDescriptors = [oldestToNewest]
                                    
                                    self.fetchRecords(query, fromDatabase: "public") {
                                        records in
                                        let oldestRecipeRecord = records[0]
                                        
                                        print("CKLOADSAVE: Resetting the loop by pointing a new daily record at the oldest recipe.")
                                        
                                        self.saveDaily(oldestRecipeRecord) {
                                            success in
                                            if success == true {
                                                self.retryFetchDaily(){recipe in completion(dailyRecipe: recipe)}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        // The rare occassion when there are NO existing daily records.
                        print("\rCKLOADSAVE: No existing Daily records found.")
                        // Try making a daily record referencing the oldest Recipe record.
                        print("CKLOADSAVE: Querying for oldest Recipe...")
                        
                        var recipeRecord: CKRecord!
                        
                        let allRecords = NSPredicate(value: true)
                        let oldestToNewest = NSSortDescriptor(key: "creationDate", ascending: true)
                        let query = CKQuery(recordType: "Recipe", predicate: allRecords)
                        query.sortDescriptors = [oldestToNewest]
                        
                        self.fetchRecords(query, fromDatabase: "public") {
                            records in
                            
                            if records.count != 0 {
                                
                                // We found the oldest Recipe, now let's create a Daily record referencing it.
                                print("\rCKLOADSAVE: Creating a first Daily record with the oldest Recipe record.")

                                recipeRecord = records[0]
                                self.saveDaily(recipeRecord) {
                                    success in
                                    if success == true {
                                        print("CKLOADSAVE: Successfully created the first Daily record.")
                                        self.retryFetchDaily(){recipe in completion(dailyRecipe: recipe)}
                                    }
                                }

                            } else {
                                
                                // If there are no Recipe records, upload a default starter recipe and use it.
                                print("CKLOADSAVE: No Recipe records found! Uploading the default...")
                                
                                let defaultDailyRecipe = LoadSave.sharedInstance.loadRecipe("SpecialRecipe")
                                self.saveRecipe(defaultDailyRecipe, toDatabase: "public"){
                                    success in
                                    
                                    // With a bit of a delay to give the database time to realize it has a new Daily record:
                                    let delay = 3.0 * Double(NSEC_PER_SEC) //Carefully tuned: 5 seconds was enough, 1.5 too little.
                                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                                    dispatch_after(time, dispatch_get_main_queue()) {
                                        print("CKLOADSAVE: Now attempting to use the default.")
                                        
                                        self.fetchRecords(query, fromDatabase: "public") {
                                            records in
                                            recipeRecord = records[0]
                                            
                                            self.saveDaily(recipeRecord) {
                                                success in
                                                if success == true {
                                                    print("CKLOADSAVE: Successfully created the first Daily record.")
                                                    self.retryFetchDaily(){recipe in completion(dailyRecipe: recipe)}
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func retryFetchDaily(completion: (dailyRecipe: Recipe) -> Void) {
        print("\rCKLOADSAVE: Retrying the fetch of the daily recipe.\r")
        
        // With a bit of a delay to give the database time to realize it has a new Daily record:
        let delay = 3.0 * Double(NSEC_PER_SEC) //Carefully tuned: 5 seconds was enough, 1.5 too little.
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.fetchDaily(){
                recipe in
                completion(dailyRecipe: recipe)
            }
        }
    }

    
    func fetchRecordForID(id: CKRecordID, recordType: String, database: String, completion: (returnRecord: CKRecord) -> Void) {
        // Here I am, reimplementing a function CloudKit already offers - fetchRecordWithID. Oh well, let's see if my version works.
        
        let idPredicate = NSPredicate(format: "recordID == %@", id)
        
        let query = CKQuery(recordType: recordType, predicate: idPredicate)
        
        fetchRecords(query, fromDatabase: database) {
            records in
            let fetchedRecord = records[0]
            completion(returnRecord: fetchedRecord)
        }
    }
    
    
    func saveDaily(recipeRecord: CKRecord, completion: (success: Bool) -> Void) {
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
        
        // Before we start the save operation, record the time - it'll come in handy in a moment.
        let startSaveTime = NSDate()
        
        // And finally save the daily record to the public database:
        saveRecord(daily, toDatabase: "public"){
            success in
            if success == true {
                print("\rCKLOADSAVE: Successfully saved a Daily record:")
                print(daily)
                print("\r")
                // Clean-up: let's delete any older Daily records that reference the same recipe.
                // This way the Daily records function more like a batting order, or a playlist on repeat.
                let sameButOlder = NSPredicate(format: "(creationDate < %@) AND (recipe == %@)", startSaveTime, referencedRecipe) //Toldya.
                let query = CKQuery(recordType: "Daily", predicate: sameButOlder)
                
                self.fetchRecords(query, fromDatabase: "public") {
                    records in
                    for record in records {
                        let id = record.objectForKey("recordID") as! CKRecordID
                        self.publicDatabase.deleteRecordWithID(id) {
                            record, error in
                            print("CKLOADSAVE: Deleted similar Daily record:")
                            print(record)
                            print("\r")
                        }
                    }
                }
                completion(success: success)
            }
        }
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
                print("CKLOADSAVE: Database '\(database)' not found. Defaulting to 'Public'.\r")
                databaseToQuery = publicDatabase
        }
        
        // Now let's query the selected database:
        databaseToQuery.performQuery(query, inZoneWithID: nil) {
            results, error in
            
            // Need to expand this to handle different errors in different ways. Below is really what should happen only if there's a connection issue. Maybe a switch statement, based on the different errors that can be returned?
            if error != nil {
                print("CKLOADSAVE: Error fetching records from the \(database) database.")
                
                switch error.code {
                    
                    case CKErrorCode.UnknownItem.rawValue:
                        print("CKLOADSAVE: Caught an UnknownItem error.")
                    
                    default:
                        print("CKLOADSAVE: Error outside the defined cases, trying to fetch again. The error is:")
                        print(error)
                        print("\r")

                        self.retryFetchRecords(query, fromDatabase: database) {
                            records in
                            completion(returnRecords: records as [CKRecord])
                        }
                }

            } else {
                // Populate the records array - which we're going to return - with the results.
                for record in results {
                    records.append(record as! CKRecord)
                }

                // And finally, send the data back to the completion block:
                completion(returnRecords: records)
            }
        }
    }
    
    
    // Here's a TOTALLY UNTESTED retry method:
    func retryFetchRecords(query: CKQuery, fromDatabase database: String, completion: (returnRecords: [CKRecord]) -> Void) {
        
        print("CLOUDSAVE: Retrying failed fetch.\r")
        
        dispatch_sync(queue) { // Should I introduce a time delay here?
            self.fetchRecords(query, fromDatabase: database) {
                records in
                completion(returnRecords: records as [CKRecord])
            }
        }
    }
    
    
    public func saveRecipes(recipes: [Recipe], toDatabase database: String, completion: (success: Bool) -> Void) {
        for recipe in recipes {
            saveRecipe(recipe, toDatabase: database){success in completion(success: success)}
        }
    }
    
    
    public func saveRecipe(recipe: Recipe, toDatabase database: String, completion: (success: Bool) -> Void) {
        
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
            self.saveRecord(recipeRecord, toDatabase: database){success in completion(success: success)}
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
        let stepTypes = record.objectForKey("stepTypes") as! [String]
        let stepValues = record.objectForKey("stepValues") as! [Double]
        
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
    
    
    func saveRecord(record: CKRecord, toDatabase database: String, completion: (success: Bool) -> Void) {
        
        print("\rCKLOADSAVE: The CKRecord we're trying to save is: ")
        print(record)
        print("\r")
        
        switch database {
            case "public":
                publicDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if let err = error {
                        // Operation failed:
                        print("CKLOADSAVE: Failed to save record to public database.")
                        print(err)
                        print("\r")
                        self.retrySaveRecord(record, toDatabase: database)
                        
                    } else {
                        // Operation succeeded:
                        print("CKLOADSAVE: Saved record to public database.\r")
                        completion(success: true)
                    }
            }
            
            case "private":
                privateDatabase.saveRecord(record) {
                    returnRecord, error in
                    
                    if error != nil {
                        // Operation failed:
                        print("CKLOADSAVE: Failed to save record to private database.")
                        print(error)
                        print("\r")
                        
                        self.retrySaveRecord(record, toDatabase: database)
                        
                    } else {
                        // Operation succeeded:
                        print("CKLOADSAVE: Saved record to private database.\r")
                        completion(success: true)
                    }
            }
            
            default:
                print("CKLOADSAVE: No database specified for save operation.\r")
        }
    }
    
    
    func retrySaveRecord(record: CKRecord, toDatabase database: String) {
        
        print("CLOUDSAVE: Retrying failed save.\r")
        dispatch_sync(queue) {
            self.saveRecord(record, toDatabase: database){success in} // Should I introduce a time delay here?
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
                        message = "but the user is not logged into iCloud, apparently?"
                        
                    case .Restricted:
                        message = "could not access user's iCloud account information."
                        
                    }
                    print("\r")
                    print(title + message + "\r")
                }
                
            })
        }
    }
    
}
