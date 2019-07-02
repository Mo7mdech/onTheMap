//
//  LoginAuth.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation

struct LogInRequest: Codable {
    let password: String
    let username: String
    let udacity: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case password
        case username
        case udacity
    }
}

struct Account: Codable {
    let registered:Bool
    let key:String
}
struct Session: Codable {
    let id:String
    let expiration:String
}

struct UserSession: Codable {
    let account:Account?
    let session:Session?
}

struct LogInSessionId: Codable{
    var sessionId: String
}

struct PostLocationResponse: Codable {
    let createdAt: String
    let objectId: String
}

struct NewLocation: Codable {
    var uniqueKey:String 
    var firstName:String?
    var lastName:String?
    var mapString:String
    var mediaURL:String
    var latitude:Double
    var longitude:Double
}
