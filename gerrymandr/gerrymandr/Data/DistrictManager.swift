//
//  DistrictManager.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 10/22/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import SQLite3
import Foundation
import CoreLocation

class DistrictManager {
    var db: OpaquePointer?
    var districtCount = 0
    
    static var sharedInstance = DistrictManager()
    
    init(){
        // gets the sql path
        let sqlPath = Bundle.main.path(forResource: "districts", ofType: "sql")
        
        if sqlite3_open(sqlPath, &db) != SQLITE_OK{
            db = nil
            NSLog("Unable to open database")
        }
        else{
            let countSQL = "SELECT COUNT(*) FROM districts"
            var countStatement: OpaquePointer? = nil
            
            // gets the total number of districts
            if sqlite3_prepare(db, countSQL, -1, &countStatement, nil) == SQLITE_OK{
                if sqlite3_step(countStatement) == SQLITE_ROW{
                    districtCount = Int(sqlite3_column_int(countStatement, 0))
                }
            }
            sqlite3_finalize(countStatement)
        }
        
    }
    
    func getRandomDistrict() -> District?{
        return getDistrict(id: Int32(arc4random_uniform(UInt32(districtCount))))
    }
    
    func getDistrict(id: Int32) -> District?{
        let selectSQL = "SELECT * FROM districts WHERE id == ?"
        var queryStatement: OpaquePointer? = nil
        
        guard let _ = db else {
            NSLog("No database...")
            return nil
        }
        
        guard sqlite3_prepare(db, selectSQL, -1, &queryStatement, nil) == SQLITE_OK else {
            NSLog("Unable to prep statement.")
            return nil
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            NSLog("Unable to bind random number.")
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            NSLog("No results found.")
            return nil
        }
        
        let id = Int(sqlite3_column_int(queryStatement, 0))
        let state = String(cString: sqlite3_column_text(queryStatement, 1))
        let district = Int(sqlite3_column_int(queryStatement, 2))
        let coordString = String(cString: sqlite3_column_text(queryStatement, 3))
        let numPeople = Int(sqlite3_column_int(queryStatement, 4))
        let numHispanic = Int(sqlite3_column_int(queryStatement, 5))
        let medAge = Double(sqlite3_column_double(queryStatement, 6))
        let medIncome = Double(sqlite3_column_double(queryStatement, 7))
        let raceString = String(cString: sqlite3_column_text(queryStatement, 8))
        let educationString = String(cString: sqlite3_column_text(queryStatement, 9))
        let centroidString = String(cString: sqlite3_column_text(queryStatement, 10))
        let adjacentCentroidString = String(cString: sqlite3_column_text(queryStatement, 11))
        let adjacentDistrictsString = String(cString: sqlite3_column_text(queryStatement, 12))
        
        sqlite3_finalize(queryStatement)
        
        var coords = [[CLLocation]]()
        var adjCentroids = [CLLocation]()
        var education = [Double]()
        var race = [Double]()
        var adjDistricts = [Int32]()
        
        let splitCentroid = centroidString.split(separator: ",")
        let centroid = CLLocation(latitude: Double(splitCentroid[1])!, longitude: Double(splitCentroid[0])!)
        
        // centroid coords are separated by spaces
        for adjCent in adjacentCentroidString.split(separator: " "){
            let splitAdjCent = adjCent.split(separator: ",")
            adjCentroids.append(CLLocation(latitude: Double(splitAdjCent[1])!, longitude: Double(splitAdjCent[0])!))
        }
        
        // | delineates polygons, spaces separate coordinates, ',' separates long and lat
        for district in coordString.split(separator: "|"){
            var tarray = [CLLocation]()
            for pair in district.split(separator: " "){
                let split = pair.split(separator: ",")
                tarray.append(CLLocation(latitude: Double(split[1])!, longitude: Double(split[0])!))
            }
            coords.append(tarray)
        }
        for raceNum in raceString.split(separator: ","){
            race.append(Double(raceNum)!)
        }
        for edNum in educationString.split(separator: ","){
            education.append(Double(edNum)!)
        }
        for dNum in adjacentDistrictsString.split(separator: ","){
            adjDistricts.append(Int32(dNum)!)
        }
        
        return District(id: id, state: state, districtNumber: district, coordinates: coords, numPeople: numPeople, numHispanic: numHispanic, medAge: medAge, medIncome: medIncome, race: race, education: education, centroid: centroid, adjCentroids: adjCentroids, adjDistricts: adjDistricts)
    }

    
}
