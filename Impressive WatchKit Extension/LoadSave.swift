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
    
    
    func loadPList(list: String) -> NSArray {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0)as NSString
        let path = documentsDirectory.stringByAppendingPathComponent(list)
        
        let fileManager = NSFileManager.defaultManager()
        
        // Check if file exists:
        if(!fileManager.fileExistsAtPath(path))
        {
            // If it doesn't, copy it from the default file in the Resources folder:
            let bundle = NSBundle.mainBundle().pathForResource("DefaultRecipes", ofType: "plist")
            
            fileManager.copyItemAtPath(bundle!, toPath: path, error:nil)
        }
        
        var data = NSArray(contentsOfFile: path)
        
        return data!
    }
    
    func saveNSArray(NSArray) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as NSString
        let path = documentsDirectory.stringByAppendingPathComponent("NewDefaults.plist")
        println("About to attempt the save!")
        
        //data.writeToFile(path, atomically: true)
        var shoppingList:[String] = ["Eggs", "Milk"]
        (shoppingList as NSArray).writeToFile(path, atomically:true)
    }
}
