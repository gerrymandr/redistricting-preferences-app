//
//  District.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 10/22/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import CoreLocation

struct District {
    var state: String
    var districtNumber: Int
    var coordinates: [CLLocation]
    var numPeople: Int
    var numHispanic: Int
    var medAge: Double
    var medIncome: Double
    
    // White, A.A, A.I., Asian, N.H.
    var race: [Double]
    
    // <HS, HS, Some College, 2 yr, 4 yr, Grad
    var education: [Double]
}
