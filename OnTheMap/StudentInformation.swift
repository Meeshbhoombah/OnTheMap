//
//  StudentInformation.swift
//  OnTheMap
//

import Foundation
import CoreLocation

struct StudentInformation {

    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    var mediaURL: String?
    let uniqueKey: String?
    let coordinates: CLLocationCoordinate2D

    init(student: [String:AnyObject]?) {

        self.firstName = student!["firstName"] as? String
        self.lastName = student!["lastName"] as? String
        self.latitude = student!["latitude"] as? Double
        self.longitude = student!["longitude"] as? Double
        self.mediaURL = student!["mediaURL"] as? String
        self.uniqueKey = student!["studentKey"] as? String
        self.coordinates = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
    }
}
