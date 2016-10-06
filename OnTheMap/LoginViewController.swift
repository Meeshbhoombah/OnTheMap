//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Rohan Mishra on 9/22/16.
//  Copyright © 2016 Rohan Mishra. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let networkRequests: NetworkRequests = NetworkRequests()
    
    // MARK:- View Controller Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fix up the UI
        enableLogin()
    }
    
    
    // MARK:- UI Methods
    
    @IBAction func login(sender: UIButton) {
        print("login IBAction called")
        login()
    }
    
    @IBAction func textFieldUpdated(_ sender: AnyObject) {
        print("textFieldUpdated called")
        enableLogin()
    }
    
    
    // MARK:- Other Methods
    
    func enableLogin() {
        loginButton.isEnabled = !(usernameField.text!.isEmpty || passwordField.text!.isEmpty)
    }
    
    func login() {
        let username: String = usernameField.text!
        let password: String = passwordField.text!
        
        NSLog("Attemping login with \(username)")
        
        // Make the call
        let loginResult = networkRequests.login(username: username, password: password)
        
        // Handle the login outcome
        switch loginResult {
        case NetworkRequests.LoginResults.success:
            NSLog("Login succeeded")
            performSegue(withIdentifier: "LoggedIn", sender: nil)
        case NetworkRequests.LoginResults.failedForCredentials:
            NSLog("Login failed for invalid credentials")
            showLoginFailureAlert(message: NSLocalizedString("LoginCredentialFailure", comment: "Credentials failure text"))
        case NetworkRequests.LoginResults.failedForNetworkingError:
            NSLog("Login failed for networking error")
            showLoginFailureAlert(message: NSLocalizedString("LoginNetworkFailure", comment: "Network failure text"))
        }
    }
    
    func showLoginFailureAlert(message: String) {
        // Construct the alert ingredients
        let alertController: UIAlertController = UIAlertController(
            title: NSLocalizedString("LoginFailureTitle", comment: "Login failed alert title"),
            message: message,
            preferredStyle:UIAlertControllerStyle.alert)
        let alertAction: UIAlertAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "Not good-OK, not bad-OK, just OK-OK"),
            style: UIAlertActionStyle.default,
            handler: nil)
        
        // Showtime!
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)

    }

}

