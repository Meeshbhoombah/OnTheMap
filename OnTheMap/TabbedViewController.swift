//
//  TabbedViewController.swift
//  OnTheMap
//

import UIKit

class TabbedViewController : UITabBarController {

    let udacityAPIHelper = UdacityAPIHelper.sharedInstance
    let parseAPIHelper = ParseAPIHelper.sharedInstance
    let studentModel = StudentModel.sharedInstance
    let alertHelper = AlertHelper.sharedInstance
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupViews()
    }
    
    override func viewDidLoad() {
        refreshView()
    }

    func loadStudentLocations() {

        mapView.mapView.layer.opacity = 1.0
        studentTableView.studentTableView.layer.opacity = 1.0
        activityIndicator.startAnimating()

        parseAPIHelper.getStudentLocations { (result, error) in

            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.alertHelper.showAlert(target: self, message: error as! String)
                })
                return
            }

            guard result == nil else {
                for i in result! {
                    self.studentModel.studentInformation.append(StudentInformation(student: i))
                }
            return
            }
        }

        // create a loading delay, otherwise load is too fast
        let triggerTime = Int64(Double(NSEC_PER_SEC) * 0.7)

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.activityIndicator.stopAnimating()
            self.mapView.mapView.layer.opacity = 1
            self.studentTableView.studentTableView.layer.opacity = 1
            self.mapView.addStudentAnnotations()
        })
    }

    func logoutOfSession() {
        udacityAPIHelper.logoutOfSession { (result, error) in

            guard error == nil else {
                self.alertHelper.showAlert(target: self, message: error as! String)
                return
            }

            guard result == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(LoginViewController(), animated: true, completion: nil)
                })
                return
            }
        }
    }

    func pinButtonPressed() {
        presentViewController(InfoPostingViewController(), animated: true, completion: nil)
    }

    func refreshView() {
        mapView.mapView.removeAnnotations(mapView.mapView.annotations)
        studentModel.studentInformation.removeAll()
        loadStudentLocations()
    }

    func setupViews() {
        let tabBarController = self
        tabBarController.setViewControllers([navigationController1, navigationController2], animated: true)
        view.addSubview(activityIndicator)
        setupConstraints()
        view.window?.rootViewController = tabBarController
        view.window?.makeKeyWindow()
    }

    func setupConstraints() {
        setupActivityIndicatorConstraints()
    }

    func setupActivityIndicatorConstraints() {

        let horizontalConstraint = NSLayoutConstraint(
            item: activityIndicator,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0)

        let verticalConstraint = NSLayoutConstraint(
            item: activityIndicator,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: view,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(horizontalConstraint)
        view.addConstraint(verticalConstraint)
    }

    lazy var navigationController1: UINavigationController = {
        let navigationController1 = UINavigationController(rootViewController: self.mapView)
        navigationController1.tabBarItem = self.mapItem
        navigationController1.navigationBar.topItem?.title = "On The Map"
        navigationController1.navigationBar.topItem?.leftBarButtonItem = self.logoutButton
        navigationController1.navigationBar.topItem?.rightBarButtonItems = [self.refreshItem, self.pinItem]
        return navigationController1
    }()

    lazy var navigationController2: UINavigationController = {
        let navigationController2 = UINavigationController(rootViewController: self.studentTableView)
        navigationController2.tabBarItem = self.listItem
        navigationController2.navigationBar.topItem?.title = "On The Map"
        navigationController2.navigationBar.topItem?.leftBarButtonItem = self.logoutButton
        navigationController2.navigationBar.topItem?.rightBarButtonItems = [self.refreshItem, self.pinItem]
        return navigationController2
    }()

    lazy var logoutButton: UIBarButtonItem = {
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: .Done,
            target: self,
            action: #selector(TabbedViewController.logoutOfSession))
        return logoutButton
    }()

    lazy var pinItem: UIBarButtonItem = {
        let pinItem = UIBarButtonItem(
            image: UIImage(named: "pin"),
            style: .Plain,
            target: self,
            action: #selector(TabbedViewController.pinButtonPressed))
        return pinItem
    }()

    lazy var refreshItem: UIBarButtonItem = {
        let refreshItem = UIBarButtonItem(
            barButtonSystemItem: .Refresh,
            target: self,
            action: #selector(TabbedViewController.refreshView))
        return refreshItem
    }()

    let mapItem: UITabBarItem = {
        let mapItem = UITabBarItem(
            title: "Map",
            image: UIImage(named: "map"),
            tag: 0)
        return mapItem
    }()

    let listItem: UITabBarItem = {
        let listItem = UITabBarItem(
            title: "List",
            image: UIImage(named: "list"),
            tag: 1)
        return listItem
    }()

    lazy var studentTableView: StudentTableViewController = {
        let view = StudentTableViewController()
        return view
    }()

    lazy var mapView: MapViewController = {
        let mapView = MapViewController()
        return mapView
    }()

    lazy var tabController : UITabBarController = {
        let tabBarController = UITabBarController()
        return tabBarController
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

}
