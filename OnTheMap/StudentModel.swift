//
//  StudentModel.swift
//  OnTheMap
//

import Foundation
import UIKit

class StudentModel {
    
    static let sharedInstance = StudentModel()
    private init() { }
    
    var studentInformation = [StudentInformation]()

}
