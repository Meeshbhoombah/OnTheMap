//
//  StudentTableViewController.swift
//  OnTheMap
//

import UIKit

class StudentTableViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    let delegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let studentModel = StudentModel.sharedInstance
    let alertHelper = AlertHelper.sharedInstance

    override func viewDidLoad() {
        setupSubviews()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")

        cell.imageView!.image = UIImage(named: "pin")

        cell.textLabel?.attributedText = NSAttributedString(
            string: "\(studentModel.studentInformation[indexPath.row].firstName!)" + " " + "\(studentModel.studentInformation[indexPath.row].lastName!)",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 18)!,
                NSForegroundColorAttributeName: UIColor.blackColor() ])

        cell.detailTextLabel?.attributedText = NSAttributedString(
            string: "\(studentModel.studentInformation[indexPath.row].mediaURL!)",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
                NSForegroundColorAttributeName: UIColor.blackColor() ])

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentModel.studentInformation.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let url = studentModel.studentInformation[indexPath.row].mediaURL!

        let app = UIApplication.sharedApplication()
        if app.canOpenURL(NSURL(string: url)!) {
            app.openURL(NSURL(string: url)!)
        } else {
            alertHelper.showAlert(target: self, message: "Invalid URL")
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

    func setupSubviews() {
        view.addSubview(studentTableView)
        setupConstraints()
    }

    func setupConstraints() {
        studentTableViewConstraints()
    }

    func studentTableViewConstraints() {

        let verticalConstraint = NSLayoutConstraint(
            item: studentTableView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Height,
            multiplier: 1.0,
            constant: 0)

        let horizontalConstraint = NSLayoutConstraint(
            item: studentTableView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0,
            constant: 0)

        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)

    }

    lazy var studentTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

}
