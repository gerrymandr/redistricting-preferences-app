//
//  StatesManager.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 4/1/18.
//  Copyright © 2018 mggg. All rights reserved.
//

import Foundation

class StatesManager{
    static var sharedInstance = StatesManager()
    
    var states = [String: State]()
    
    init(){
        // loads the state json file
        if let jsonPath = Bundle.main.path(forResource: "state_data", ofType: "json"){
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                let json = try JSONSerialization.jsonObject(with: data)
                if let json = json as? [String: [String: Any]]{
                    for (key, val) in json{
                        states[key] = State(name: key, json: val)
                    }
                }
            }
            catch{
                NSLog("Unable to load states")
            }
        }
    }
}
