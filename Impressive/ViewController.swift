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
        // Do any additional setup after loading the view, typically from a nib.
        
//        let specialRecipe = LoadSave.sharedInstance.loadRecipe("SpecialRecipe")
//        
//        println("VC: Attempting to save to the Cloud... ")
//        CKLoadSave.sharedInstance.saveRecipe(specialRecipe, toPublicDatabase: true)
        
        let savedRecipes = LoadSave.sharedInstance.loadRecipes("SavedRecipes")
        CKLoadSave.sharedInstance.saveRecipes(savedRecipes, toPublicDatabase: false)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

