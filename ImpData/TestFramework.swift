//
//  Test.swift
//  Impressive
//
//  Created by Andrew Schmidt on 3/8/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import Foundation

public class Test: NSObject {
    
    var x: Bool
    
    public init(_ x: Bool) {
        self.x = x
        if self.x {
            print("Framework is accessible!")
        } else {
            print("Framework is accessible!")
        }
    }
}