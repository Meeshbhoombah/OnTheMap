//
//  UdacityAPIHelper.swift
//  OnTheMap
//

import Foundation
import UIKit

class UdacityAPIHelper {

    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

    static let sharedInstance = UdacityAPIHelper()
    private init() { }

    func createSession(username username: String, password: String, completionHandler: (result: Bool?, error: AnyObject?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in

            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }

            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let json = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! NSDictionary

            guard json["error"] == nil else {
                completionHandler(result: nil, error: json["error"])
                return
            }

            if let account = json["account"] as? [String:AnyObject] {
                self.delegate.key = account["key"] as! String
                self.delegate.registered = true
                completionHandler(result: true, error: nil)
            }
        }
        task.resume()
    }

    func getUserInformation(key: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(key)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in

            if error != nil {
                print(error)

            } else {

                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let json = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! NSDictionary

                if let user = json["user"] as? [String:AnyObject] {
                    if let firstName = user["first_name"] as? String {
                        self.delegate.firstName = firstName
                    }
                    if let lastName = user["last_name"] as? String {
                        self.delegate.lastName = lastName
                    }
                }
            }
        }
        task.resume()
    }

    func logoutOfSession(completionHandler: (result: Bool?, error: AnyObject?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()

        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }   

        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else{
                completionHandler(result: nil, error: error)
                return
            }

            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let json = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! NSDictionary

            guard json["error"] == nil else {
                completionHandler(result: nil, error: json["error"])
                return
            }

            guard (json["session"] as? [String:AnyObject]) == nil else {
                completionHandler(result: true, error: nil)
                return
            }
        }
        task.resume()
    }
}
