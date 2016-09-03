//
//  ParseAPIHelper.swift
//  OnTheMap
//

import Foundation
import UIKit

class ParseAPIHelper {

    static let sharedInstance = ParseAPIHelper()
    private init() { }

    // MARK: Get Student Location
    func getStudentLocations(completionHandler: (result: [[String:AnyObject]]?, error: AnyObject?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.HTTPMethod = "GET"

        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let response = response as? NSHTTPURLResponse
            
            guard response?.statusCode != 401 else {
                completionHandler(result: nil, error: "Unable to authorize with server.")
                return
            }

            guard error == nil else {
                completionHandler(result: nil, error: error?.localizedDescription)
                return
            }
            
            if let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
                if let results = json["results"] as! [[String:AnyObject]]? {
                    completionHandler(result: results, error: nil)
                }
            }
        }
        task.resume()
    }

    // MARK: Post Student Location
    func postStudentLocation(key: String, firstName: String, lastName: String, lat: Double, lon: Double, mapString: String, url: String, completionHandler: (result: [String:AnyObject]?, error: AnyObject?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(key   )\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(url)\",\"latitude\": \(lon), \"longitude\": \(lon)}".dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                completionHandler(result: nil, error: error)
                return
            }

            guard response == nil else {
                if let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
                    completionHandler(result: json, error: nil)
                }
                return
            }
        }
        task.resume()
    }
}
