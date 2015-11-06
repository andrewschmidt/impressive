//
//  LoadSave.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/25/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import CloudKit

public class LoadSave: NSObject {
    
    // Set this thing up as a singleton, so it's not all in the global space.
    // Accessible via LoadSave.sharedInstance.
    
    public class var sharedInstance: LoadSave {
        struct Singleton {
            static let instance = LoadSave()
        }
        return Singleton.instance
    }
    
    
    public func savedDailyIsCurrent() -> Bool {
        if let dateModified = getDateModified("SavedDaily") where dateIsCurrent(dateModified) == true {
            return true
        } else {
            return false
        }
    }
    
    
    public func loadDaily(completion: (daily: Recipe) -> Void) {
        // STEPS:
        
        // 1. Check if the "SavedDaily" is current. If so, load it and return it.
        if let dateModified = getDateModified("SavedDaily") where dateIsCurrent(dateModified) == true {
            
            print("\rLOADSAVE: The recipe in SavedDaily is current, loading it.")
            
            let dailyRecipe = loadRecipe("SavedDaily")
            completion(daily: dailyRecipe)
            
        } else {
        
            // 2. Check to see if there's a Daily recipe in "NextDaily". If so, save it into SavedDaily, clear it from NextDaily, load it and return it.
            if let dateModified = getDateModified("NextDaily") where dateIsCurrent(dateModified) {
                
                print("\rLOADSAVE: The recipe saved in NextDaily is current, moving it to SavedDaily and loading it.")
                
                let nextDailyRecipe = loadRecipe("NextDaily")
                
                overwriteRecipesInPlist("SavedDaily", withRecipes: [nextDailyRecipe])
                deletePlist("NextDaily")
                
                completion(daily: nextDailyRecipe)
                
            } else {
            
                // 3. Run fetchDaily(). Save the result into SavedDaily. Load it and return it.
                print("\rLOADSAVE: Didn't have a usable daily recipe in storage, attempting to fetch one...")
                CKLoadSave.sharedInstance.fetchDaily() {
                    dailyRecipe in
                    print("\rLOADSAVE: Received a daily recipe from the network! Saving it and re-running loadDaily().")
                    
                    self.overwriteRecipesInPlist("SavedDaily", withRecipes: [dailyRecipe])
                    
                    self.loadDaily() {
                        dailyRecipe in
                        completion(daily: dailyRecipe)
                    }
                    
                }
            }
        }
    }
    
    func dateIsCurrent(date: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar() // or = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let today = NSDate()
        let startDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: today, options: NSCalendarOptions(rawValue: 0))!
        let endDate = calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: today, options: NSCalendarOptions(rawValue: 0))!
        
        if date > startDate && date < endDate {
            return true
        } else {
            return false
        }
    }
    
    func getDateCreated(plistName: String) -> NSDate? {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.AndrewSchmidt.Impressive")
        let file = url!.URLByAppendingPathComponent("\(plistName).plist")
        
        if !fileManager.fileExistsAtPath(file.path!) {
            // If it doesn't exists, we need to know that. or return nil?
            return nil
        } else {
            // If it does, return the date.
            let attributes: NSDictionary = try! fileManager.attributesOfItemAtPath(file.path!)
            let creationDate = attributes.fileCreationDate()
            return creationDate
        }

    }
    
    func getDateModified(plistName: String) -> NSDate? {
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.AndrewSchmidt.Impressive")
        let file = url!.URLByAppendingPathComponent("\(plistName).plist")
        
        if !fileManager.fileExistsAtPath(file.path!) {
            // If it doesn't exists, we need to know that. or return nil?
            return nil
        } else {
            // If it does, return the date.
            let attributes: NSDictionary = try! fileManager.attributesOfItemAtPath(file.path!)
            let modifiedDate = attributes.fileModificationDate()
            return modifiedDate
        }
    }
    
    
    public func saveRecipe(recipe: Recipe, inPlistNamed plistName: String) {
        // First let's load the plist as-is.
        var savedRecipes = loadRecipes(plistName)
        
        // Then append the recipe we want to save.
        savedRecipes.append(recipe)
        
        // Then re-save the recipe array.
        overwriteRecipesInPlist(plistName, withRecipes: savedRecipes)
    }
    
    
    public func deleteRecipe(recipe: Recipe, inPlistNamed plistName: String) {
        // First let's load the plist as-is.
        var savedRecipes = loadRecipes(plistName)
        
        // Then find the recipe we want to delete and remove it from the array.
        var index = 0
        for savedRecipe in savedRecipes {
            if savedRecipe.name == recipe.name {
                savedRecipes.removeAtIndex(index)
                break
            }
            ++index
        }
        
        // Finally re-save the recipe array.
        overwriteRecipesInPlist(plistName, withRecipes: savedRecipes)
    }
    
    
    public func overwriteRecipe(oldRecipeName: String, withRecipe newRecipe: Recipe, inPlistNamed plistName: String) {
        var savedRecipes = loadRecipes(plistName)
        var foundRecipe = false
        
        for i in 0 ..< savedRecipes.count {
            let name = savedRecipes[i].name
            
            if name == oldRecipeName {
                savedRecipes[i] = newRecipe
                print("LOADSAVE: Replacing recipe named \"\(name)\" with \"\(newRecipe.name).\"")
                foundRecipe = true
            }
        }
        
        if foundRecipe {
            overwriteRecipesInPlist(plistName, withRecipes: savedRecipes)
        } else {
            print("LOADSAVE: Overwrite failed! Couldn't find a recipe named \"\(oldRecipeName)\" in \(plistName).plist.")
        }
    }
    
    
    public func overwriteRecipesInPlist(plistName: String, withRecipes recipes: [Recipe]) {
        // First we need to convert all the recipes in the array into NSDictionaries.
        // Let's make a place to save them:
        var recipesAsDicts = [NSDictionary]()
        
        // Now let's convert:
        for recipe in recipes {
            let recipeAsDictionary = recipe.convertToNSDictionary()
            recipesAsDicts.append(recipeAsDictionary)
        }

        // Finally let's save the whole thing:
        LoadSave.sharedInstance.saveNSArray(recipesAsDicts as NSArray, withName: plistName)
    }
    
    
    public func loadRecipe(plistName: String) -> Recipe {
        let recipeInArray = loadRecipes(plistName)
        let recipe = recipeInArray[0] as Recipe
        return recipe
    }
    
    
    public func loadRecipes(plistName: String) -> [Recipe] {
        
        // First let's load the plist of saved recipes.
        // The loadPlist function is smart enough to fill in the default recipes if there aren't any saved ones.
        let savedRecipesPlistAsArray = loadPlist(plistName) as Array
        
        // Next we need to convert each of the NSDictionaries in the plist to Recipes.
        var savedRecipes = [Recipe]()
        
        for recipeAsNSDict in savedRecipesPlistAsArray {
            let recipe = Recipe(fromDictionary: recipeAsNSDict as! NSDictionary)
            savedRecipes.append(recipe)
        }
       
        return savedRecipes
    }
   
    
    public func deletePlist(list: String) { //Should probably be private.
        
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.AndrewSchmidt.Impressive")
        let file = url!.URLByAppendingPathComponent("\(list).plist")
        
        // Check if file exists:
        if fileManager.fileExistsAtPath(file.path!) == true {
            // If it does, delete it.
            print("LOADSAVE: Deleting file at path: \(file.path!)")
            do {
                try fileManager.removeItemAtPath(file.path!)
            } catch _ {
            }
        }
    }
    
    
    private func loadPlist(list: String) -> NSArray {
        
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.AndrewSchmidt.Impressive")
        let file = url!.URLByAppendingPathComponent("\(list).plist")
        
        // Check if file exists:
        if !fileManager.fileExistsAtPath(file.path!) {
            // If it doesn't, copy it from the default file in the Resources folder:
            print("LOADSAVE: No existing data found, copying Default\(list).plist to the device.")
            let bundle = NSBundle.mainBundle().pathForResource("Default\(list)", ofType: "plist")
            do {
                try fileManager.copyItemAtPath(bundle!, toPath: file.path!)
                print("LOADSAVE: Copied the file to \(file.path!).")
            } catch _ {
                print("LOADSAVE: Failed to copy.")
            }
        }
        
        let data = NSArray(contentsOfFile: file.path!)
        return data!
        
    }
    
    
    private func saveNSArray(array: NSArray, withName name: String) {
        
        let fileManager = NSFileManager.defaultManager()
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.AndrewSchmidt.Impressive")
        let file = url!.URLByAppendingPathComponent("\(name).plist")
        
        array.writeToFile(file.path!, atomically: true)
        print("LOADSAVE: Saved the array to \(file.path!)")
        
    }

}
