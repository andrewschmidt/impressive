//
//  ViewController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/17/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Just checking to make sure everything's working:
        let specialRecipe = LoadSave.sharedInstance.loadRecipe("SpecialRecipe")
        println(specialRecipe.name)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

