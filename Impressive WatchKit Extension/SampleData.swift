//
//  SampleData.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/23/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit

let savedRecipes = [
    Recipe(
        name: "Marco's Best",
        steps: [
            Step("Heat", howHotCelsius: 80.6),
            Step("Pour", howMuch: 40),
            Step("Stir", howLong: 15),
            Step("Press", howLong: 75)]
    ),
    
    Recipe(
        name: "Andrew's Attempt",
        steps: [
            Step("Heat", howHotFahrenheit: 212.0),
            Step("Pour", howMuch: 10),
            Step("Stir", howLong: 5),
            Step("Pour", howMuch: 30),
            Step("Stir", howLong: 15),
            Step("Press", howLong: 65)]
    ),
    
    Recipe(
        name: "Lindsay's Latte",
        steps: [
            Step("Heat", howHotFahrenheit: 200.0),
            Step("Pour", howMuch: 35),
            Step("Stir", howLong: 5),
            Step("Press", howLong: 40)]
    ),
    
    Recipe(
        name: "Brad's Boilin' Brew",
        steps: [
            Step("Heat", howHotCelsius: 100.0),
            Step("Pour", howMuch: 38),
            Step("Stir", howLong: 7),
            Step("Press", howLong: 50)]
    ),
    
    Recipe(
        name: "Carlos' Cup",
        steps: [
            Step("Heat", howHotCelsius: 78.0),
            Step("Pour", howMuch: 5),
            Step("Stir", howLong: 5),
            Step("Pour", howMuch: 30),
            Step("Press", howLong: 55)]
    ),
]