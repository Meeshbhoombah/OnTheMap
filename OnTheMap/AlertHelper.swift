//
//  AlertHelper.swift
//  OnTheMap
//

import UIKit

class AlertHelper {

    static let sharedInstance = AlertHelper()
    private init() { }

    func showAlert(target target: UIViewController, message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let okay = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alert.addAction(okay)
        target.presentViewController(alert, animated: true, completion: nil)
    }
}
