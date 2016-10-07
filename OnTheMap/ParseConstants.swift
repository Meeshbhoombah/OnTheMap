//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/12/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import Foundation

// MARK: ParseClient (Constants)
extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        
        // URLS
        static let Scheme = "https"
        static let Host = "parse.udacity.com"
        static let APIPath = "/parse/classes/StudentLocation"
        
        // API Keys
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: Methods
    struct Methods {
        static let Update = "/{objectID}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let ObjectID = "objectID"
    }
    
    // MARK: HTTP Header Fields
    struct HTTPHeaderFields {
        static let ApplicationID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let ContentType = "Content-Type"
    }
    
    // MARK: HTTP Header Values
    struct HTTPHeaderValues {
        static let JSON = "application/json"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Where = "where"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    // MARK: JSON Keys
    struct JSONKeys {
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Created = "createdAt"
        static let Updated = "updatedAt"
    }
    
    // MARK: Notifications
    struct Notifications {
        static let Updated = Notification.Name("Updated")
    }

}
