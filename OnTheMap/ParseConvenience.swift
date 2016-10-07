//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Mark Yang on 9/12/16.
//  Copyright © 2016 Myang. All rights reserved.
//

import Foundation

// MARK: ParseClient (Convenient Resource Methods)
extension ParseClient {

    func getStudentLocations(completionHandlerForStudentLocations: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let url = getURL()
        let headers = commonHeaders
        let parameters: [String: AnyObject] = [
            ParameterKeys.Limit: 100 as AnyObject,
            ParameterKeys.Order: "-\(JSONKeys.Updated)" as AnyObject
        ]
        let getStudentLocationsError = NSError(domain: "getStudentLocations", code: ErrorCodes.Parse, userInfo: [NSLocalizedDescriptionKey: ErrorStrings.FailedStudentLocationsUpdate])
        
        taskForGETMethod(baseURL: url, httpHeaders: headers, parameters: parameters) { (result, error) in
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                print(error)
                
                completionHandlerForStudentLocations(false, getStudentLocationsError)
                return
            }
            
            if let result = result?[JSONKeys.Results] as? [[String: AnyObject]] {
                let studentLocations = StudentLocation.studentLocationsFromResults(result)
                self.studentLocations = studentLocations
                
                completionHandlerForStudentLocations(true, nil)
            } else {
                completionHandlerForStudentLocations(false, getStudentLocationsError)
            }
        }
    }
}
