//
//  LoadSave.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/25/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class LoadSave: NSObject {
    
    // Set this thing up as a singleton, so it's not all in the global space.
    // Accessible via LoadSave.sharedInstance.
    
    class var sharedInstance: LoadSave {
        struct Singleton {
            static let instance = LoadSave()
        }
        return Singleton.instance
    }
    
    
    func saveRecipe(recipe: Recipe, inPlistNamed plistName: String) {
        // First let's load the plist as-is.
        var savedRecipes = loadRecipes(plistName)
        
        // Then append the recipe we want to save.
        savedRecipes.append(recipe)
        
        // Then re-save the recipe array.
        overwriteRecipesInPlist(plistName, withRecipes: savedRecipes)
    }
    
    
    func overwriteRecipe(oldRecipeName: String, withRecipe newRecipe: Recipe, inPlistNamed plistName: String) {
        var savedRecipes = loadRecipes(plistName)
        var foundRecipe = false
        
        for i in 0 ..< savedRecipes.count {
            let name = savedRecipes[i].name
//            println("LOADSAVE: Checking recipe named \"\(name).\"")
            
            if name == oldRecipeName {
                savedRecipes[i] = newRecipe
                println("LOADSAVE: Replacing recipe named \"\(name)\" with \"\(newRecipe.name).\"")
                foundRecipe = true
            }
        }
        
        if foundRecipe {
            overwriteRecipesInPlist(plistName, withRecipes: savedRecipes)
        } else {
            println("LOADSAVE: Overwrite failed! Couldn't find a recipe named \"\(oldRecipeName)\" in \(plistName).plist.")
        }
    }
    
    
    func overwriteRecipesInPlist(plistName: String, withRecipes recipes: [Recipe]) {
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
    
    
    func loadRecipe(plistName: String) -> Recipe {
        let recipeInArray = loadRecipes(plistName)
        let recipe = recipeInArray[0] as Recipe
        return recipe
    }
    
    
    func loadRecipes(plistName: String) -> [Recipe] {
        
        // First let's load the plist of saved recipes.
        // The loadPlist function is smart enough to fill in the default recipes if there aren't any saved ones.
        var savedRecipesPlistAsArray = LoadSave.sharedInstance.loadPlist(plistName) as Array
        
        // Next we need to convert each of the NSDictionaries in the plist to Recipes.
        // Here's where we're going to put them:
        var savedRecipes = [Recipe]()
        
        // And here's the loop:
        for recipeAsNSDict in savedRecipesPlistAsArray {
            let currentRecipeName = recipeAsNSDict["name"] as String
            var currentRecipeSteps = [Step]()
            
            // Let's make some Step objects!
            let recipeStepsAsNSDicts = recipeAsNSDict["steps"] as NSArray
            
            for stepAsNSDict in recipeStepsAsNSDicts {
                
                // First we need to interpret the StepType from a string.
                var currentStepType: StepType!
                let stepTypeAsString = stepAsNSDict["type"] as String
                
                switch stepTypeAsString as String {
                case "Heat":
                    currentStepType = StepType.Heat
                case "Pour":
                    currentStepType = StepType.Pour
                case "Stir":
                    currentStepType = StepType.Stir
                case "Press":
                    currentStepType = StepType.Press
                default:
                    println("LOADSAVE: Could not assign a StepType for \(stepTypeAsString).")
                }
                
                // Then we need to figure out which particular value this step has, and pass the amount.
                var currentStep: Step!
                
                if let currentStepHowLong: Int = stepAsNSDict["howLong"] as? Int {
                    currentStep = Step(currentStepType, howLong: currentStepHowLong)
                }
                if let currentStepHowMuch: Int = stepAsNSDict["howMuch"] as? Int {
                    currentStep = Step(currentStepType, howMuch: currentStepHowMuch)
                }
                if let currentStepHowHotFahrenheit: Double = stepAsNSDict["howHotFahrenheit"] as? Double {
                    currentStep = Step(currentStepType, howHotFahrenheit: currentStepHowHotFahrenheit)
                }
                if let currentStepHowHotCelsius: Double = stepAsNSDict["howHotCelsius"] as? Double {
                    currentStep = Step(currentStepType, howHotCelsius: currentStepHowHotCelsius)
                }
                
                // Finally, add the Step to the array of Steps in the recipe.
                currentRecipeSteps.append(currentStep)
            }
            
            // And make a Recipe of it all:
            let currentRecipe = Recipe(name: currentRecipeName, steps: currentRecipeSteps)
            savedRecipes.append(currentRecipe)
        }
       
        return savedRecipes
    }
    
    
    private func loadPlist(list: String) -> NSArray {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0)as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("\(list).plist")
        let fileManager = NSFileManager.defaultManager()
        
        // Check if file exists:
        if(!fileManager.fileExistsAtPath(path))
        {
            println("LOADSAVE: No existing data found, copying Default\(list).plist to the device.")
            // If it doesn't, copy it from the default file in the Resources folder:
            let bundle = NSBundle.mainBundle().pathForResource("Default\(list)", ofType: "plist")
            
            var error: NSError?
            
            if (fileManager.copyItemAtPath(bundle!, toPath: path, error: &error)) {
                println("LOADSAVE: Copied the file to \(path).")
            }
            else {
                println("LOADSAVE: Failed to copy because \(error).")
            }
        }
        
        var data = NSArray(contentsOfFile: path)
        return data!
    }
    
    
    private func saveNSArray(array: NSArray, withName name: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("\(name).plist")
        
        array.writeToFile(path, atomically: true)
//        println("LOADSAVE: Saved the array to \(path)")
    }
}
