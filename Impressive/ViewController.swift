//
//  ViewController.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/17/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let plistData = Recipe(name: "Marcos' Test", steps: [Step(.Press, howLong: 30)])
        println(plistData)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

