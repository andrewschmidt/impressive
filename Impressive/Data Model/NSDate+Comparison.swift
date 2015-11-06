//
//  NSDate+Comparison.swift
//  Impressive
//
//  Created by Andrew Schmidt on 5/21/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

// This extends NSDate to be comparable by >, <, and ==.

import Foundation

//extension NSDate: Equatable {} // Started throwing a "redundant conformance" error in Swift 2.
extension NSDate: Comparable {}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}