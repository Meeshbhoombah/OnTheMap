//
//  MapViewController.swift
//  OnTheMap
//

import UIKit
import MapKit
import CoreLocation

class MapViewController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let delegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let studentModel = StudentModel.sharedInstance
    let alertHelper = AlertHelper.sharedInstance

    override func viewDidLoad() {
        setupSubViews()
        locationManager.requestWhenInUseAuthorization()
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "annotationPin"
        var annotationPinView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationPin") as? MKPinAnnotationView

        if annotationPinView == nil {
            annotationPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationPinView?.canShowCallout = true
            annotationPinView?.pinTintColor = UIColor.redColor()
            annotationPinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            annotationPinView?.annotation = annotation
        }

        return annotationPinView
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let urlToOpen = view.annotation?.subtitle! {
                if app.canOpenURL(NSURL(string: urlToOpen)!) {
                    app.openURL(NSURL(string: urlToOpen)!)
                } else {
                    alertHelper.showAlert(target: self, message: "Invalid URL")
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

    func addStudentAnnotations() {

        var annotations = [MKAnnotation]()
        for i in studentModel.studentInformation {

            var nameHolder = ""
            let annotation = MKPointAnnotation()

            if i.firstName == nil || i.firstName!.isEmpty {
                nameHolder += "" + " "
            } else {
                nameHolder += i.firstName! + " "
            }

            if i.lastName == nil {
                nameHolder += "" + " "
            } else {
                nameHolder += i.lastName!
            }

            if i.mediaURL == nil || i.mediaURL!.isEmpty {
                annotation.subtitle = ""
            } else {
                annotation.subtitle = i.mediaURL!
            }

            annotation.title = nameHolder
            annotation.coordinate = i.coordinates
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }

    // MARK: - Setup Subviews

    func setupSubViews() {
        view.addSubview(mapView)
        setupConstraints()
    }

    // MARK: - Constraints

    func setupConstraints() {
        setupMapViewConstraints()
    }

    func setupMapViewConstraints() {

        let topConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0)

        let bottomConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0)

        let leftConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Left,
            multiplier: 1.0,
            constant: 0)

        let rightConstraint = NSLayoutConstraint(
            item: mapView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Right,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(topConstraint)
        view.addConstraint(bottomConstraint)
        view.addConstraint(leftConstraint)
        view.addConstraint(rightConstraint)
    }

    // MARK: - Lazily Instantiated Objects

    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }

        return manager
    }()

    lazy var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self

        return view
    }()

}
