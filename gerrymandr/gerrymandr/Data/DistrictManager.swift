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
    var fipsDictionary: Dictionary<String, String>
    
    static var sharedInstance = DistrictManager()
    
    init(){
        let sqlPath = Bundle.main.path(forResource: "districts", ofType: "sql")
        let statesPath = Bundle.main.path(forResource: "states", ofType: "plist")
        
        if sqlite3_open(sqlPath, &db) != SQLITE_OK{
            db = nil
            NSLog("Unable to open database")
        }
        else{
            let countSQL = "SELECT COUNT(*) FROM districts"
            var countStatement: OpaquePointer? = nil
            
            if sqlite3_prepare(db, countSQL, -1, &countStatement, nil) == SQLITE_OK{
                if sqlite3_step(countStatement) == SQLITE_ROW{
                    districtCount = Int(sqlite3_column_int(countStatement, 0))
                }
            }
            sqlite3_finalize(countStatement)
        }
        
        fipsDictionary = NSDictionary(contentsOfFile: statesPath!) as! Dictionary<String, String>
    }
    
    func getRandomDistrict() -> District?{
        let i = Int32(arc4random_uniform(UInt32(districtCount)))
        
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
        
        guard sqlite3_bind_int(queryStatement, 1, i) == SQLITE_OK else {
            NSLog("Unable to bind random number.")
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            NSLog("No results found.")
            return nil
        }
        
        let state = Int(sqlite3_column_int(queryStatement, 1))
        let district = Int(sqlite3_column_int(queryStatement, 2))
        let coordString = String(cString: sqlite3_column_text(queryStatement, 3))
        
        sqlite3_finalize(queryStatement)
        
        var coords = [CLLocation]()
        
        for pair in coordString.split(separator: " "){
            let split = pair.split(separator: ",")
            coords.append(CLLocation(latitude: Double(split[0])!, longitude: Double(split[1])!))
        }
        
        return District(stateCode: state, districtNumber: district, coordinates: coords)
    }
    
    func getStateName(district: District) -> String{
        return fipsDictionary[String(district.stateCode)]!
    }
    
}
