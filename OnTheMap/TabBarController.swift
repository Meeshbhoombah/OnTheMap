//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/14/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    // MARK: Properties
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create navigation bar items
        navigationItem.title = "On The Map"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getStudentLocations)),
            UIBarButtonItem(image: UIImage(named: "Pin"), style: .plain, target: self, action: #selector(postLocation))
        ]

        getStudentLocations()
    }
}

// MARK: TableViewController (Actions)
extension TabBarController {
    
    func logout() {
        dismiss(animated: true, completion: nil)
        udacityClient.logout()
    }
    
    func getStudentLocations() {
        parseClient.getStudentLocations { (success, error) in
            if success {
                NotificationCenter.default.post(name: ParseClient.Notifications.Updated, object: nil)
            } else {
                if let error = error {
                    displayError(host: self, error: error)
                }
            }
        }
    }
    
    func postLocation() {
        
    }
}
