//
//  ViewController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/17/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData
import CloudKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let recipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
//        CKLoadSave.sharedInstance.saveRecipes(recipes, toPublicDatabase: false)
        
        
//        println("VC: Attempting to fetch recipes from the cloud with a completion block...")
//        
//        CKLoadSave.sharedInstance.fetchPersonalRecipes() {
//            
//            (recipes: [Recipe]) in
//            
//            // I could put any code in here - like updating UI!
//            // For now let's keep it simple.
//            println("VC: And here they are, fetched and ready:")
//            println(recipes)
//            
//        }
//
//        println("VC: While we wait for that to finish, let's move on...")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

