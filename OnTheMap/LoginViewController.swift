//
//  LoginViewController.swift
//  OnTheMap
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    internal var username: String?
    internal var password: String?

    let parseAPIHelper = ParseAPIHelper.sharedInstance
    let udacityHelper = UdacityAPIHelper.sharedInstance
    let studentModel = StudentModel.sharedInstance
    let alertHelper = AlertHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orangeColor()
        setupSubviews()
    }

    // MARK:- Actions

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func loginButtonPressed(sender: UIButton!) {

        username = emailTextField.text
        password = passwordTextField.text

        if emailTextField.text == "" {
            alertHelper.showAlert(target: self, message: "Please enter an email address.")
        }

        else if passwordTextField.text == "" {
            alertHelper.showAlert(target: self, message: "Please enter a password.")
        }

        parseAPIHelper.getStudentLocations { (result, error) in

            guard error == nil else {
                
                if (error! as! String) == "401" {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alertHelper.showAlert(target: self, message: "Error authenticating with the server")
                    })

                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.alertHelper.showAlert(target: self, message: error as! String)
                    })
                }

                return
            }

            guard result == nil else {

                for i in result! {
                    self.studentModel.studentInformation.append(StudentInformation(student: i))
                }
                self.createUdacitySession()
                return
            }
        }
        
    }

    func createUdacitySession() {
        udacityHelper.createSession(username: username!, password: password!) { result, error in

            guard result == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.udacityHelper.getUserInformation(self.appDelegate.key)
                })

                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(TabbedViewController(), animated: false, completion: nil)
                })

                return
            }

            guard error == nil else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if error?.code == -1002 {
                            self.alertHelper.showAlert(target: self, message: "Failed to connect to server.")
                        }
                        else {
                            self.alertHelper.showAlert(target: self, message: "\(error)")
                        }
                    })
                return
            }
        }
    }

    func signupWebViewPressed(sender: UIButton!) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.udacity.com")!)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Setup Subviews

    func setupSubviews() {
        view.addSubview(udacityLogo)
        view.addSubview(loginToUdacityLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signupButton)
        setupConstraints()
    }

    // MARK: - Constraints

    func setupConstraints() {
        setupUdacityLogoConstraints()
        setupLoginLabelConstraints()
        setupEmailTextfieldConstraints()
        setupPasswordTextfieldConstraints()
        setupLoginButtonConstraints()
        setupSignupButtonConstraints()
    }

    // MARK: ImageView Contraints

    func setupUdacityLogoConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: udacityLogo,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: udacityLogo,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: loginToUdacityLabel,
            attribute: .Top,
            multiplier: 1,
            constant: -20)

        udacityLogo.addConstraint(NSLayoutConstraint(
            item: udacityLogo,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 75))

        udacityLogo.addConstraint(NSLayoutConstraint(
            item: udacityLogo,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 75))

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    // MARK: Login Label Constraints

    func setupLoginLabelConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: loginToUdacityLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: loginToUdacityLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1,
            constant: -70)

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    // MARK: Username TextField Constraints

    func setupEmailTextfieldConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: emailTextField,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: emailTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: loginToUdacityLabel,
            attribute: .Bottom,
            multiplier: 1,
            constant: 25)

        emailTextField.addConstraint(NSLayoutConstraint(
            item: emailTextField,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 300))

        emailTextField.addConstraint(NSLayoutConstraint(
            item: emailTextField,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 45))

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    // MARK: Password Textfield Constraints

    func setupPasswordTextfieldConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: passwordTextField,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: passwordTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: emailTextField,
            attribute: .Bottom,
            multiplier: 1,
            constant: 5)

        passwordTextField.addConstraint(NSLayoutConstraint(
            item: passwordTextField,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 300))

        passwordTextField.addConstraint(NSLayoutConstraint(
            item: passwordTextField,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 45))

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    // MARK: Login Button Constraints

    func setupLoginButtonConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: loginButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: loginButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: passwordTextField,
            attribute: .Bottom,
            multiplier: 1,
            constant: 15)

        loginButton.addConstraint(NSLayoutConstraint(
            item: loginButton,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 300))

        loginButton.addConstraint(NSLayoutConstraint(
            item: loginButton,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 45))

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    func setupSignupButtonConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: signupButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: signupButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: loginButton,
            attribute: .Bottom,
            multiplier: 1,
            constant: 15)

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    // MARK: - Lazily Instantiated Objects

    lazy var udacityLogo: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "udacity")

        return view
    }()

    lazy var loginToUdacityLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Login to Udacity"
        view.textColor = UIColor.whiteColor()
        view.font = UIFont(name: "Helvetica", size: 18)

        return view
    }()

    lazy var emailTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocapitalizationType = .None
        view.autocorrectionType = .No
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.5)

        let paddingView = UIView(frame: CGRectMake(0, 0, 10, view.frame.height))
        view.leftView = paddingView
        view.leftViewMode = .Always

        var myAttributedText = NSMutableAttributedString(
            string: "Email",
            attributes: [NSForegroundColorAttributeName : UIColor.init(white: 1, alpha: 1)])
        view.attributedPlaceholder = myAttributedText
        view.textColor = UIColor.init(white: 1, alpha: 1)
        view.delegate = self

        return view
    }()

    lazy var passwordTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocapitalizationType = .None
        view.autocorrectionType = .No
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        view.secureTextEntry = true
        let paddingView = UIView(frame: CGRectMake(0, 0, 10, view.frame.height))
        view.leftView = paddingView
        view.leftViewMode = .Always

        var myAttributedText = NSMutableAttributedString(
            string: "Password",
            attributes: [NSForegroundColorAttributeName : UIColor.init(white: 1, alpha: 1)])
        view.attributedPlaceholder = myAttributedText
        view.textColor = UIColor.init(white: 1, alpha: 1)

        view.delegate = self

        return view
    }()
    
    lazy var loginButton: UIButton = {
        let view = UIButton(type: .System)
        view.setTitle("Login", forState: .Normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor ( red: 0.9373, green: 0.2431, blue: 0.0235, alpha: 1.0 )
        view.tintColor = UIColor.whiteColor()
        view.layer.cornerRadius = 3
        view.adjustsImageWhenHighlighted = true
        view.addTarget(self, action: #selector(self.loginButtonPressed(_:)), forControlEvents: .TouchUpInside)

        return view
    }()

    lazy var signupButton: UIButton = {
       let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Don't have an account? Sign Up", forState: .Normal)
        view.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        view.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        view.backgroundColor = UIColor.orangeColor()
        view.addTarget(self, action: #selector(self.signupWebViewPressed(_:)), forControlEvents: .TouchUpInside)

        return view
    }()

}
