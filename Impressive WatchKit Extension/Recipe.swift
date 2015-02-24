//
//  Recipe.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    var name: String
    var steps: [Step]
    
    init(name: String, steps: [Step]) {
        self.name = name
        self.steps = steps
    }
}
