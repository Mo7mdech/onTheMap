//
//  LocationAuth.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation

struct AllStudentInfo : Codable {
    
    let results:[StudentInformation]
}

struct SingleStudentInfo: Codable {
    let results: StudentInformation
}

struct StudentInformation: Codable {
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
    
    var fullName: String {
        var name = ""
        if firstName != nil {
            name = "\(firstName!)"
            if lastName != nil {
                name = "\(firstName!) \(lastName!)"
            } else {
                name = "\(lastName!)"
            }
        } else {
            name = "No Name Available"
        }
        return name
    }
    
    var userUrl: String {
        if mediaURL != nil {
            return  "\(mediaURL!)"
        }
        return ""
    }
}

struct StudentInfo: Codable {
    let nickname: String //= "Jarad"
}

struct User: Codable {
    let lastname: String
    enum CodingKeys: String, CodingKey {
        case lastname = "last_name"
    }
}

struct UserInfo: Codable {
    
    var firstName: String
    var lastName: String
    var longitude: Double
    var latitude: Double
    var mediaUrl: String
    var mapString: String
    var objectId: String
    var uniqueKey: String
    
}
