//
//  District.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 10/22/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import CoreLocation

class District {
    var id: Int
    var state: String
    var districtNumber: Int
    var coordinates: [[CLLocation]]
    var numPeople: Int
    var numHispanic: Int
    var medAge: Double
    var medIncome: Double
    var centroid: CLLocation
    var adjCentroids: [CLLocation]
    var adjDistricts: [Int32]

    
    // White, A.A, A.I., Asian, N.H.
    var race: [Double]
    
    // <HS, HS, Some College, 2 yr, 4 yr, Grad
    var education: [Double]
    
    // Full map, graph, demographics, race, income, education (to be added)
    var viewedStats = Array(repeating: false, count: 7)
    var fair = false
    var startedViewing = Date()
    var stoppedViewing: Date?
    
    init(id: Int, state: String, districtNumber: Int, coordinates: [[CLLocation]], numPeople: Int, numHispanic: Int, medAge: Double, medIncome: Double, race: [Double], education: [Double], centroid: CLLocation, adjCentroids: [CLLocation], adjDistricts: [Int32]){
        self.id = id
        self.state = state
        self.districtNumber = districtNumber
        self.coordinates = coordinates
        self.numPeople = numPeople
        self.numHispanic = numHispanic
        self.medAge = medAge
        self.medIncome = medIncome
        self.race = race
        self.education = education
        self.centroid = centroid
        self.adjCentroids = adjCentroids
        self.adjDistricts = adjDistricts
    }
}
