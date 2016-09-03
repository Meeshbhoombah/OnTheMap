//
//  InfoPostingViewController.swift
//  OnTheMap
//

import UIKit
import MapKit
import QuartzCore

class InfoPostingViewController : UIViewController, UIViewControllerTransitioningDelegate, MKMapViewDelegate, UITextFieldDelegate {

    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let parseAPIHelper = ParseAPIHelper.sharedInstance
    let alertHelper = AlertHelper.sharedInstance

    // MARK:- ViewController Lifecycle

    override func viewWillAppear(animated: Bool) {
        switchHiddenUIElements(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }

    func switchHiddenUIElements(hidden: Bool) {
        if hidden == false {
            mapView.hidden = true
            submitButton.hidden = true
            linkTextField.hidden = true
            lightCancelButton.hidden = true

        } else {

            findOnMapButton.hidden = true
            topGrayRect.hidden = true
            locationTextField.hidden = true
            bottomGrayRect.layer.opacity = 0.5
            mapView.hidden = false
            submitButton.hidden = false
            linkTextField.hidden = false
            lightCancelButton.hidden = false
        }
    }

    func changeOpacity(input: Bool) {
        if (input) {
            findOnMapButton.layer.opacity = 0.5
            topGrayRect.layer.opacity = 0.5
            locationTextField.layer.opacity = 0.5
            bottomGrayRect.layer.opacity = 0.5
        } else {
            findOnMapButton.layer.opacity = 1
            topGrayRect.layer.opacity = 1
            locationTextField.layer.opacity = 1
            bottomGrayRect.layer.opacity = 1
        }
    }

    func cancelButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func forwardGeocode() {
        if locationTextField.text == "" {
            alertHelper.showAlert(target: self, message: "Please enter an address or a city.")
        } else {

            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()

            self.changeOpacity(true)

            CLGeocoder().geocodeAddressString(locationTextField.text!, inRegion: nil, completionHandler: { (placemarks, error) in

                guard error == nil else {

                    guard error?.code != 8 else {
                        self.alertHelper.showAlert(target: self, message: "Failed to geocode input.")
                        self.activityIndicator.stopAnimating()
                        self.changeOpacity(false)
                        return
                    }

                    self.alertHelper.showAlert(target: self, message: "\(error)")
                    self.activityIndicator.stopAnimating()
                    self.changeOpacity(false)
                    return
                }

                self.activityIndicator.stopAnimating()
                self.switchHiddenUIElements(true)

                // parse JSON values
                self.appDelegate.latitude  = placemarks![0].location?.coordinate.latitude
                self.appDelegate.longitude = placemarks![0].location?.coordinate.longitude
                self.appDelegate.mapString = placemarks![0].addressDictionary!["Name"]! as? String

                // add annotation & center map on it
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = self.appDelegate.latitude!
                annotation.coordinate.longitude = self.appDelegate.longitude!

                self.mapView.addAnnotation(annotation)
                self.mapView.centerCoordinate = annotation.coordinate
                self.mapView.scrollEnabled = false
                self.mapView.pitchEnabled = false
                self.mapView.zoomEnabled = false
                self.mapView.rotateEnabled = false

                let radius : CLLocationDistance = 1500
                let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, radius, radius)
                self.mapView.setRegion(region, animated: true)
                
            })
        }
    }

    func submitButtonPressed() {
        if linkTextField.text == "" {
            alertHelper.showAlert(target: self, message: "Please enter a link.")
        } else {

        let app = UIApplication.sharedApplication()

        // check if textfield has http:// and correct if not
        if (!linkTextField.text!.hasPrefix("http://")) {
            linkTextField.text! = "http://" + linkTextField.text!
        }

        // if textfield has a proper url
        if app.canOpenURL(NSURL(string: linkTextField.text!)!) && linkTextField.text! != "" {
            appDelegate.url = linkTextField.text!
            parseAPIHelper.postStudentLocation(appDelegate.key!, firstName: appDelegate.firstName!, lastName: appDelegate.lastName!, lat: appDelegate.latitude!, lon: appDelegate.longitude!, mapString: appDelegate.mapString!, url: appDelegate.url!, completionHandler: { (result, error) in
                
                guard error == nil else {
                    self.alertHelper.showAlert(target: self, message: "\(error)")
                    return
                }
                
                guard result == nil else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(TabbedViewController(), animated: true, completion: nil)
                    }
                    return
                }
            })

        } else {
            alertHelper.showAlert(target: self, message: "Invalid URL")
            }
        }
    }

    // MARK: - Dismissing Keyboard

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.font = UIFont.init(name: "Helvetica", size: 22)!
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        if locationTextField.text! == "" {
            locationTextField.resignFirstResponder()
        } else {
            locationTextField.resignFirstResponder()
            forwardGeocode()

            if linkTextField.hidden == false {
                linkTextField.resignFirstResponder()
                submitButtonPressed()
            }
        }
        return true
    }

    // MARK:- Subviews & Constraints Setup

    func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(topGrayRect)
        view.addSubview(bottomGrayRect)
        view.addSubview(locationTextField)
        view.addSubview(findOnMapButton)
        view.addSubview(submitButton)
        view.addSubview(linkTextField)
        view.addSubview(darkCancelButton)
        view.addSubview(lightCancelButton)
        view.addSubview(activityIndicator)
        setupConstraints()
    }

    func setupConstraints() {
        setupMapViewConstraints()
        setupTopGrayRect()
        setupBottomGrayRect()
        setupLinkTextField()
        setupTextFieldConstraints()
        setupFindOnMapButtonConstraints()
        setupSubmitButtonConstraints()
        setupDarkCancelButtonConstraints()
        setupLightCancelButtonConstraints()
        setupActivityIndicator()
    }

    // Top Gray Rect Constraints

    func setupTopGrayRect() {

        let topConstraint = NSLayoutConstraint(
            item: topGrayRect,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)

        let heightConstraint = NSLayoutConstraint(
            item: topGrayRect,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 200)

        let horizontalConstraint = NSLayoutConstraint(
            item: topGrayRect,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(topConstraint)
        view.addConstraint(horizontalConstraint)
        view.addConstraint(heightConstraint)
    }

    // Bottom Gray Rect Constraints

    func setupBottomGrayRect() {

        let verticalConstraint = NSLayoutConstraint(
            item: bottomGrayRect,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 100)

        let horizontalConstraint = NSLayoutConstraint(
            item: bottomGrayRect,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        let bottomConstraint = NSLayoutConstraint(
            item: bottomGrayRect,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
        view.addConstraint(bottomConstraint)
    }

    func setupLinkTextField() {

        let topConstraint = NSLayoutConstraint(
            item: linkTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)

        let heightConstraint = NSLayoutConstraint(
            item: linkTextField,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: 200)

        let horizontalConstraint = NSLayoutConstraint(
            item: linkTextField,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(topConstraint)
        view.addConstraint(horizontalConstraint)
        view.addConstraint(heightConstraint)
    }
    
    func setupTextFieldConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: locationTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: topGrayRect,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: locationTextField,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        let bottomConstraint = NSLayoutConstraint(
            item: locationTextField,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: bottomGrayRect,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
        view.addConstraint(bottomConstraint)
    }

    func setupMapViewConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Height,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    func setupFindOnMapButtonConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: findOnMapButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: bottomGrayRect,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: findOnMapButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: bottomGrayRect,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    func setupSubmitButtonConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: submitButton,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: bottomGrayRect,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: submitButton,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: bottomGrayRect,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    func setupDarkCancelButtonConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: darkCancelButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 12)

        let horizontalConstraint = NSLayoutConstraint(
            item: darkCancelButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0,
            constant: -10)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    func setupLightCancelButtonConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: lightCancelButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 12)

        let horizontalConstraint = NSLayoutConstraint(
            item: lightCancelButton,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0,
            constant: -10)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    func setupActivityIndicator() {

        let verticalConstraint = NSLayoutConstraint(
            item: activityIndicator,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: activityIndicator,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
    }

    // MARK:- Lazily Instantiated Objects

    lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 )
        textField.clearsOnBeginEditing = true
        textField.textColor = UIColor.whiteColor()

        textField.font = UIFont.init(name: "Helvetica", size: 22)!
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter Your Location Here",
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSBackgroundColorAttributeName: UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 ),
                NSFontAttributeName: UIFont.init(name: "Helvetica", size: 22)! ])

        textField.textAlignment = .Center
        textField.contentVerticalAlignment = .Top
        textField.autocapitalizationType = .Words
        textField.clearsOnBeginEditing = true

        // add padding to textfield
        textField.layer.sublayerTransform =  CATransform3DMakeTranslation(0, 15, 0)

        return textField
    }()

    lazy var linkTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 )
        textField.clearsOnBeginEditing = true
        textField.textColor = UIColor.whiteColor()

        textField.font = UIFont.init(name: "Helvetica", size: 24)!
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter a Link to Share Here",
            attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSBackgroundColorAttributeName: UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 ),
                NSFontAttributeName: UIFont.init(name: "Helvetica", size: 24)! ])

        textField.textAlignment = .Center
        textField.contentVerticalAlignment = .Center
        textField.autocapitalizationType = .None
        textField.clearsOnBeginEditing = true
        textField.autocorrectionType = .No

        // add padding to textfield
        textField.layer.sublayerTransform =  CATransform3DMakeTranslation(0, 15, 0)
        textField.keyboardType = .URL

        return textField
    }()

    lazy var topGrayRect: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor ( red: 0.851, green: 0.851, blue: 0.8353, alpha: 1.0 )
        label.numberOfLines = 3
        label.textAlignment = .Center

        let studyingBold = NSMutableAttributedString(
            string: "studying\n",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 30)!,
                NSForegroundColorAttributeName: UIColor.blueColor() ])

        let labelTextUltraThin = NSMutableAttributedString(
            string: "Where are you\nstudying\ntoday?",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-UltraLight", size: 30)!,
                NSForegroundColorAttributeName: UIColor.blueColor() ])

        let text = NSMutableAttributedString.init(attributedString: labelTextUltraThin)
        text.replaceCharactersInRange(NSRange(location: 14,length: 9), withAttributedString: studyingBold)
        label.attributedText = text

        return label
    }()

    lazy var bottomGrayRect: UILabel = {
        let btmRect = UILabel()
        btmRect.translatesAutoresizingMaskIntoConstraints = false
        btmRect.backgroundColor = UIColor ( red: 0.851, green: 0.851, blue: 0.8353, alpha: 1.0 )

        return btmRect
    }()

    lazy var findOnMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Find on the Map", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(InfoPostingViewController.forwardGeocode), forControlEvents: .TouchUpInside)

        return button
    }()

    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(InfoPostingViewController.submitButtonPressed), forControlEvents: .TouchUpInside)

        return button
    }()

    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self

        return mapView
    }()

    lazy var darkCancelButton: UIButton = {
        let darkCancelButton = UIButton()
        darkCancelButton.translatesAutoresizingMaskIntoConstraints = false
        darkCancelButton.setTitle("Cancel", forState: .Normal)
        darkCancelButton.setTitleColor(UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 ), forState: .Normal)
        darkCancelButton.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        darkCancelButton.adjustsImageWhenHighlighted = true
        darkCancelButton.addTarget(self, action: #selector(InfoPostingViewController.cancelButtonPressed), forControlEvents: .TouchUpInside)

        return darkCancelButton
    }()

    lazy var lightCancelButton: UIButton = {
        let lightCancelButton = UIButton()
        lightCancelButton.translatesAutoresizingMaskIntoConstraints = false
        lightCancelButton.setTitle("Cancel", forState: .Normal)
        lightCancelButton.setTitleColor(UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 ), forState: .Normal)
        lightCancelButton.setTitleColor(UIColor ( red: 0.2549, green: 0.4588, blue: 0.6471, alpha: 1.0 ), forState: .Highlighted)
        lightCancelButton.adjustsImageWhenHighlighted = true
        lightCancelButton.addTarget(self, action: #selector(InfoPostingViewController.cancelButtonPressed), forControlEvents: .TouchUpInside)

        return lightCancelButton
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

}
