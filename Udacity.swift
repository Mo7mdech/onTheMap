//
//  Udacity.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 19/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation

class Udacity: NSObject {
    
    
    let session = URLSession.shared
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    struct Auth {
        static var sessionID = ""
        static var userKey = ""
        static var userName = ""
    }
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        case logIn
        case singleStudentLocation
        case delete
        
        
        var stringValue: String {
            switch self {
                
            case .logIn:
                return "https://onthemap-api.udacity.com/v1/session"
            case .singleStudentLocation:
                return "https://onthemap-api.udacity.com/v1/users/\(Auth.userKey)"
            case .delete:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    class func requestSignedInUserInfo(completionHandler: @escaping (StudentInfo?,Error?)->Void) {
        let url = EndPoints.singleStudentLocation.url
        print("url => ",url)
        var request = URLRequest(url: url)
        request.addValue(ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(Auth.userKey, forHTTPHeaderField: "User-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
           // let range = Range(5..<data.count)
            let newData = data.subdata(in: 5..<data.count)
            let jsonDecoder = JSONDecoder()
            do {
                let result = try jsonDecoder.decode(StudentInfo.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(result, nil)
                    print("requestSignedInUserInfo result: ",result)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    class func taskForPOSTRequest(url: URL, body: String, completion: @escaping (
        Data?, Error?) -> Void)-> URLSessionDataTask{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            
            switch (statusCode) {
            case 403:
                sendError("Please check your credentials and try again.")
            case 200 ..< 299:
                break
            default:
                sendError("Your request returned a status code other than 2xx!")
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            var newData = data
           // let range = Range(5..<data.count)
            newData = data.subdata(in: 5..<data.count)
            
            completion(newData, nil)
        }
        task.resume()
        return task
    }
    
    class func logInUdacity(password: String, username: String, completion: @escaping (Bool, Error?)->Void){
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        _ = taskForPOSTRequest(url: EndPoints.logIn.url, body: body, completion: { (data, error) in
            if let error = error {
                print(error)
                completion(false, error)
            } else {
                let userSessionData = self.parseUserSession(data: data)
                if let sessionData = userSessionData.0 {
                    guard let account = sessionData.account, account.registered == true else {
                        completion(false, error)
                        return
                    }
                    guard let userSession = sessionData.session else {
                        completion(false, error)
                        return
                    }
                    Auth.userKey = account.key
                    print("AuthKey = \(Auth.userKey)")
                    UserDefaults.standard.set(account.key, forKey: "accountKey")
                    UserDefaults.standard.set(userSession.id, forKey: "UserSession")
                    Auth.sessionID = userSession.id
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        })
    }
    
    class func taskForDelete(completion: @escaping ()-> Void){
        var request = URLRequest(url: EndPoints.logIn.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("enter task for delete")
            let range = 5..<data!.count
            _ = data?.subdata(in: range)
            Auth.sessionID = ""
            Auth.userKey = ""
        }
        task.resume()
    }
    
    class func parseUserSession(data: Data?) -> (UserSession?, Error?) {
        var studensLocation: (userSession: UserSession?, error: Error?) = (nil, nil)
        do {
            if let data = data {
                let jsonDecoder = JSONDecoder()
                studensLocation.userSession = try jsonDecoder.decode(UserSession.self, from: data)
            }
        } catch {
            print("Could not parse the data as JSON: \(error.localizedDescription)")
            let userInfo = [NSLocalizedDescriptionKey : error]
            studensLocation.error = NSError(domain: "parseUserSession", code: 1, userInfo: userInfo)
        }
        return studensLocation
    }
}

