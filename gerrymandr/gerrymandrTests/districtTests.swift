//
//  gerrymandrTests.swift
//  gerrymandrTests
//
//  Created by Gabriel Ramirez on 10/23/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import XCTest

class districtTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectRandomDistrictTest() {
        let dManager = DistrictManager.sharedInstance
        
        guard let randDist = dManager.getRandomDistrict() else{
            XCTFail("Unable to fetch random district")
            return
        }
        
        XCTAssert(randDist.coordinates.count != 0, "Coordinates not properly split.")
    }
    
    
}
