//
//  StudentLocationStruct.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/12/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import Foundation

struct StudentLocation {
    
    // MARK: Properties
    var objectID: String
    var uniqueKey: String?
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var created: String
    var updated: String
    
    // MARK: Initializers
    init(dictionary: [String: AnyObject]) {
        objectID  = dictionary[ParseClient.JSONKeys.ObjectID] as? String ?? ""
        uniqueKey = dictionary[ParseClient.JSONKeys.UniqueKey] as? String ?? ""
        firstName = dictionary[ParseClient.JSONKeys.FirstName] as? String ?? ""
        lastName  = dictionary[ParseClient.JSONKeys.LastName] as? String ?? ""
        mapString = dictionary[ParseClient.JSONKeys.MapString] as? String ?? ""
        mediaURL  = dictionary[ParseClient.JSONKeys.MediaURL] as? String ?? ""
        latitude  = dictionary[ParseClient.JSONKeys.Latitude] as? Double ?? 0.0
        longitude = dictionary[ParseClient.JSONKeys.Longitude] as? Double ?? 0.0
        created   = dictionary[ParseClient.JSONKeys.Created] as? String ?? ""
        updated   = dictionary[ParseClient.JSONKeys.Updated] as? String ?? ""
    }
    
    static func studentLocationsFromResults(_ results: [[String: AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()
        
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
