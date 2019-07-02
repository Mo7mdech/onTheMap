//
//  Parse.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation

class Parse{
    
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case allStudentLocation
        case singleStudentLocation
        case orderedStudentsLocation
        
        var stringValue: String {
            switch self {
            case .allStudentLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100"
            case .singleStudentLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .orderedStudentsLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func requestGetStudents(url: URL, completionHandler: @escaping ([StudentInformation]?,Error?)->Void) {
        var request = URLRequest(url: url)
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            //print("get students data : ",data)
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(AllStudentInfo.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(result.results, nil)
                   // print("requestGetStudents result: ",result)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    class func requestOrderedLocations(completion: @escaping([StudentInformation]?, Error?)->Void){
        requestGetStudents(url: EndPoints.orderedStudentsLocation.url) { (response, error) in
            guard let response = response else {
                print("RequestOrderedLocations: Failed")
                completion(nil, error)
                return
            }
            completion(response,nil)
        }
    }
    
    class func requestLimitedStudents(completion: @escaping ([StudentInformation]?, Error?)-> Void){
        requestGetStudents(url: EndPoints.allStudentLocation.url) { (response, error) in
            guard let response = response else {
                print("requestLimitedStudents: Failed")
                completion(nil, error)
                return
            }
            completion(response,nil)
        }
    }
    
    
    class func requestPostStudentInfo(postData:NewLocation, completionHandler: @escaping (PostLocationResponse?,Error?)->Void) {
        let endpoint:URL = EndPoints.singleStudentLocation.url
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("postData: ",postData)
        let jsonEncoder = JSONEncoder()
        let encodedPostData = try! jsonEncoder.encode(postData)
        request.httpBody = encodedPostData
        print("encodedPostData: ",encodedPostData)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let data = data
            {
                if error != nil {
                    return
                }
                print("data=> ",data.base64EncodedString())
                guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                    return
                }
                print("httpStatusCode: ",httpStatusCode)
                if httpStatusCode >= 200 && httpStatusCode < 300 {
                    print("post students data : ",data)
                    let jsonDecoder = JSONDecoder()
                    do {
                        print(data.base64EncodedString())
                        let decodedData = try jsonDecoder.decode(PostLocationResponse.self, from: data)
                        print("decodedData : ",decodedData)
                        DispatchQueue.main.async {
                            completionHandler(decodedData,nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completionHandler(nil,error)
                        }
                    }
                }
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    DispatchQueue.main.async {
                        completionHandler(nil,NSError(domain: "requestPostStudentInfo", code: 1, userInfo: userInfo))
                    }
                }
                    switch (httpStatusCode){
                    case 200..<300 :
                        break
                    case 400 :
                        sendError("Bad Request")
                    case 401 :
                        sendError("Invalid Credentials")
                    case 403:
                        sendError("Unauthorized")
                    case 405:
                        sendError("HttpMethod Not Allowed")
                    case 410:
                        sendError("URL Changed")
                    case 500:
                        sendError("Server Error")
                    default:
                        sendError("Unknown error")
                    }
                return
            }
        }
        task.resume()
    }
    
}
