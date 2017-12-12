//
//  AWSManager.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 12/10/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSDynamoDB
import FBSDKLoginKit

class AWSManager{
    static var sharedInstance = AWSManager()
    
    var dynamoDB: AWSDynamoDB?
    var id: String?
    var isAuthenticated = false
    
    let credProvider: AWSCognitoCredentialsProvider
    
    init(){
        credProvider = AWSCognitoCredentialsProvider(regionType: .USEast2, identityPoolId: "us-east-2:f872974e-2a10-46e0-95fd-83cd6beadfbe", identityProviderManager: FacebookProvider())
        let configuration = AWSServiceConfiguration(region: .USEast2, credentialsProvider: credProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Automatically gets AWS credentials when FB authentication is complete
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKAccessTokenDidChange, object: nil, queue: nil) {
            [unowned self] note in
            self.setupAWS()
        }
    }
    
    func setupAWS(){
        credProvider.getIdentityId().continueWith(block: {[unowned self](task) -> AnyObject? in
            if task.error != nil{
                print(task.error!)
            }
            else{
                self.id = String(task.result!)
                self.dynamoDB = AWSDynamoDB.default()
                self.isAuthenticated = true
            }
            return task
        })
    }
    
    func submitDistrictEval(district: District){
        guard let _ = id else{
            NSLog("Not logged in.")
            return
        }
        
        guard let _ = dynamoDB else{
            NSLog("DynamoDB not initialized")
            return
        }
        
        let userID = AWSDynamoDBAttributeValue()
        userID?.s = id!
        
        let update = AWSDynamoDBUpdateItemInput()
        update?.tableName = "GerrymandrResponses"
        update?.key = ["userID": userID!]
        
        // Setup update parameters
        let fair = AWSDynamoDBAttributeValue()
        let timeToDecide = AWSDynamoDBAttributeValue()
        let viewedMap = AWSDynamoDBAttributeValue()
        let viewedDemos = AWSDynamoDBAttributeValue()
        let viewedRace = AWSDynamoDBAttributeValue()
        let viewedIncome = AWSDynamoDBAttributeValue()
        let viewedEd = AWSDynamoDBAttributeValue()
        
        fair?.boolean = district.fair as NSNumber
        timeToDecide?.n = String(district.stoppedViewing!.timeIntervalSince(district.startedViewing))
        viewedMap?.boolean = district.viewedStats[0] as NSNumber
        viewedDemos?.boolean = district.viewedStats[1] as NSNumber
        viewedRace?.boolean = district.viewedStats[2] as NSNumber
        viewedIncome?.boolean = district.viewedStats[3] as NSNumber
        viewedEd?.boolean = district.viewedStats[4] as NSNumber

        let value = AWSDynamoDBAttributeValue()
        value?.m = ["fair": fair!, "timeToDecide": timeToDecide!, "viewedMap": viewedMap!, "viewedDemographics":viewedDemos!, "viewedRace": viewedRace!, "viewedIncome":viewedIncome!, "viewedEducation": viewedEd!]
        
        let valueUpdate = AWSDynamoDBAttributeValueUpdate()
        valueUpdate?.value = value
        valueUpdate?.action = .put
        
        update?.attributeUpdates = ["\(district.id)": valueUpdate!]
        
        dynamoDB?.updateItem(update!).continueWith(){ (task:AWSTask<AWSDynamoDBUpdateItemOutput>) -> Any? in
            if let error = task.error {
                print("The request failed. Error: \(error)")
                return nil
            }
        return nil
        }
    }
    
}
class FacebookProvider: NSObject, AWSIdentityProviderManager{
    func logins() -> AWSTask<NSDictionary> {
        if let token = FBSDKAccessToken.current().tokenString{
            return AWSTask(result: [AWSIdentityProviderFacebook:token])
        }
        return AWSTask(error: NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
    }
}
