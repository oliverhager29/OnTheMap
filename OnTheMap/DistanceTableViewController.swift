//
//  DistanceTableViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/3/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

/// DistanceTableViewController - shows a table of student locations within a given distance. Pressing on a row opens a web pages with the student's link. The list can be reloaded, a new location for the current logged in user can be posted and it can be logged out of the Udacity account.
class DistanceTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate {
    /// error alert when there is a problem retrieving all locations
    var alert: UIAlertController!
    
    /// warning alert when the user tries to post its location even if a location already have been posted
    var overwriteAlert: UIAlertController!
    
    /// error alert when having a problem getting public user data of the current logged in Udacity account
    var getPublicUserDataAlert: UIAlertController!
    
    /// error alert when having a problem getting the locations of the other students
    var getStudentLocationsAlert: UIAlertController!
    
    /// distance in miles
    @IBOutlet weak var distanceTextField: UITextField!
    
    /// activity indicator for loading the locations
    @IBOutlet weak var tableActivityIndicator: UIActivityIndicatorView!
    
    /// navigation item for adding a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    /// location table view
    @IBOutlet weak var locationsTableView: UITableView!
    
    /// location manager
    let locationManager = CLLocationManager()
    
    /// add second right button
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization();
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            if(locationManager.location != nil) {
                UdacityClient.sharedInstance().userData.longitude = locationManager.location!.coordinate.longitude
                UdacityClient.sharedInstance().userData.latitude = locationManager.location!.coordinate.latitude
            }
        }
        else{
            println("Location service disabled");
        }
        var postLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postLocation")
        myNavigationItem.rightBarButtonItems?.append(postLocationButton)
    }
    
    /// check whether the location for the current logged in user already has been posted and show a warning alert if so
    func checkPostLocation() {
        self.tableActivityIndicator.startAnimating()
        if let userData = UdacityClient.sharedInstance().userData {
            let firstName = userData.firstName
            let lastName = userData.lastName
            ParseClient.sharedInstance().getStudentLocationsByCriteria(0, limit: 100, criteriaJSON: "{ \"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\" }") { locations, error in
                if let locations = locations {
                    if locations.count > 0 {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableActivityIndicator.stopAnimating()
                            self.presentViewController(self.overwriteAlert, animated: true, completion: nil)
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableActivityIndicator.stopAnimating()
                            self.postLocation()
                        }
                    }
                }
                else {
                    println(error)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableActivityIndicator.stopAnimating()
                        self.presentViewController(self.getStudentLocationsAlert, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    /// navigate to the post location page
    func postLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        performSegueWithIdentifier("postLocation", sender: controller)
    }
    
    /// initalize alerts and table with locations
    /// :param: animated specifies whether view appears animated
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getStudentLocationsAlert = UIAlertController(title: "Error", message: "Reading student locations failed", preferredStyle: UIAlertControllerStyle.Alert)
        self.getStudentLocationsAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.getPublicUserDataAlert = UIAlertController(title: "Error", message: "Getting public user data failed", preferredStyle: UIAlertControllerStyle.Alert)
        self.getPublicUserDataAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.tableActivityIndicator.startAnimating()
        UdacityClient.sharedInstance().getPublicUserData()  { (result, errorString) in
            if let result = result as UserData! {
                let firstName = result.firstName
                let lastName = result.lastName
                dispatch_async(dispatch_get_main_queue(), {
                    self.overwriteAlert = UIAlertController(title: "Error", message: "User \(firstName) \(lastName) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: UIAlertControllerStyle.Alert)
                    self.overwriteAlert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { action in
                        switch action.style{
                        case .Default:
                            println("overwrite location")
                            self.postLocation()
                        case .Cancel:
                            println("cancel location posting")
                        case .Destructive:
                            println("destructive")
                        }
                    }))
                    self.overwriteAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.tableActivityIndicator.stopAnimating()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableActivityIndicator.stopAnimating()
                    self.presentViewController(self.getPublicUserDataAlert, animated: true, completion: nil)
                })
            }
        }
        self.distanceTextField.delegate = self
    }

    /// return number of locations (rows)
    /// :param: tableView table view
    /// :param: section section in table (there is only one)
    /// :returns: number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(UdacityClient.sharedInstance().userData.latitude != nil && UdacityClient.sharedInstance().userData.longitude != nil && self.distanceTextField.text.toInt() != nil) {
            return StudentLocationRepository.getLocations(UdacityClient.sharedInstance().userData.latitude!, fromLong: UdacityClient.sharedInstance().userData.longitude!, withInDistance: Double(self.distanceTextField.text.toInt()!), activityIndicator: tableActivityIndicator).count
        }
        else {
            return StudentLocationRepository.getLocationCount(tableActivityIndicator)
        }
    }
    
    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "LocationDistanceTableViewCell"
        var location: StudentLocation
        if(UdacityClient.sharedInstance().userData.latitude != nil && UdacityClient.sharedInstance().userData.longitude != nil && self.distanceTextField.text.toInt() != nil) {
            let locations = StudentLocationRepository.getLocations(UdacityClient.sharedInstance().userData.latitude!, fromLong: UdacityClient.sharedInstance().userData.longitude!, withInDistance: Double(self.distanceTextField.text.toInt()!), activityIndicator: tableActivityIndicator)
            location = locations[indexPath.row]
        }
        else {
            location = StudentLocationRepository.getLocations(indexPath.row, activityIndicator: tableActivityIndicator)
        }
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        /* Set cell defaults */
        var firstNameStr = ""
        if(location.firstName != nil) {
            firstNameStr = location.firstName!
        }
        var lastNameStr = ""
        if(location.lastName != nil) {
            lastNameStr = location.lastName!
        }
        cell.textLabel!.text = "\(firstNameStr) \(lastNameStr)"
        cell.imageView!.image = UIImage(named: "pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        return cell
    }
    
    /// react on table row (student location) selected and open web page for link of selected location
    /// :param: tableView table view
    /// :param: indexPath row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = StudentLocationRepository.locations[indexPath.row]
        if let url = location.mediaURL {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    /// height for row to be displayed
    /// :param: tableView table view
    /// :param: indexPath row
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    /// dismiss current page (login page will be re-displayed)
    func logoutButtonTouchUp() {
        self.tableActivityIndicator.startAnimating();
        UdacityClient.sharedInstance().deleteSession() { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                self.tableActivityIndicator.stopAnimating()
            })
            if success {
                println("Logout successful")
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.performSegueWithIdentifier("logout", sender: controller)
                    
                })
                FacebookClient.sharedInstance().logout()
            }
            else {
                println("Logout failed: \(errorString)")
            }
        }
    }
    
    /// login button pressed
    /// :param: sender login button
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logoutButtonTouchUp()
    }
    
    /// reload button pressed
    /// :param: sender reload button
    @IBAction func reloadButtonPressed(sender: UIBarButtonItem) {
        StudentLocationRepository.reset()
        self.locationsTableView.reloadData()
    }
    
    /// update location
    /// :param: manager location manager
    /// :param: locations locations
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue : CLLocationCoordinate2D = manager.location.coordinate;
        let span2 = MKCoordinateSpanMake(1, 1)
        let long = locValue.longitude;
        let lat = locValue.latitude;
        let loadlocation = CLLocationCoordinate2D(
            latitude: lat, longitude: long
            
        )
        UdacityClient.sharedInstance().userData.latitude = lat
        UdacityClient.sharedInstance().userData.longitude = long
        locationManager.stopUpdatingLocation();
    }
    
    /// hides text field after return
    /// :param: textField text field
    /// :returns: true
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        self.locationsTableView.reloadData()
        return true;
    }
}