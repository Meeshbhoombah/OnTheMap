//
//  AppConstants.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/14/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import UIKit

// MARK: Errors
struct ErrorCodes {
    // Use 0 for non-display errors
    static let User = 1
    static let Udacity = 2
    static let Parse = 3
}

struct ErrorStrings {
    static let EmptyCredentials = "Email or password field empty."
    static let FailedLogin = "Login failed."
    static let FailedStudentLocationsUpdate = "Could not update student locations."
    static let EmptyURL = "No URL found"
}

// MARK: Alerts
struct AlertActions {
    static let Dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
}
