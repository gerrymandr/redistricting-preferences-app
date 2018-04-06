//
//  State.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 4/1/18.
//  Copyright © 2018 mggg. All rights reserved.
//

struct State {
    var name: String
    var numPeople: Int
    var numHispanic: Int
    
    var medAge: Double
    var medIncome: Double
    
    // White, A.A, A.I., Asian, N.H.
    var race: [Double]
    
    // <HS, HS, Some College, 2 yr, 4 yr, Grad
    var education: [Double]
    
    init(name: String, numPeople: Int, numHispanic: Int, race: [Double], education: [Double], medAge: Double, medIncome: Double){
        self.name = name
        self.numPeople = numPeople
        self.numHispanic = numHispanic
        self.race = race
        self.education = education
        self.medAge = medAge
        self.medIncome = medIncome
    }
    
    init?(name: String, json: [String: Any]){
        guard let people = json["people"] as? Int,
                let hispanic = json["hispanic"] as? Int,
                let race = json["race"] as? [Double],
                let education = json["education"] as? [Double],
                let medAge = json["medage"] as? Double,
                let medIncome = json["medinc"] as? Double
        else{
                return nil
        }
        
        self.name = name
        self.numPeople = people
        self.numHispanic = hispanic
        self.race = race
        self.education = education
        self.medIncome = medIncome
        self.medAge = medAge
    }
}
