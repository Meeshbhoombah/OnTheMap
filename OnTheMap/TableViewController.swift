//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/13/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    // MARK: Properties
    let parseClient = ParseClient.sharedInstance()
    var studentLocations = [StudentLocation]()
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentLocations = parseClient.studentLocations

        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsUpdated), name: ParseClient.Notifications.Updated, object: nil)
    }

    func studentLocationsUpdated() {
        studentLocations = parseClient.studentLocations
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
}

// MARK: TableViewController: UITableViewDelegate, UITableViewDataSource
extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell
        let cellReuseIdentifier = "TableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // Set cell defaults
        let studentLocation = studentLocations[(indexPath as NSIndexPath).row]
        cell?.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.imageView!.image = UIImage(named: "Pin")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return studentLocations.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: studentLocations[indexPath.row].mediaURL) else {
            displayError(host: self, error: NSError(domain: "tableView", code: ErrorCodes.User, userInfo: [NSLocalizedDescriptionKey: ErrorStrings.EmptyURL]))
            return
        }

        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

