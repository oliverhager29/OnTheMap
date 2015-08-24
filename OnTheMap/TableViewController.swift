//
//  TableViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/3/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit

/// TableViewController - shows a table of student locations. Pressing on a row opens a web pages with the student's link. The list can be reloaded, a new location for the current logged in user can be posted and it can be logged out of the Udacity account.
class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    /// students' locations
    var locations: [StudentLocation] = []
    
    /// error alert when there is a problem retrieving all locations
    var alert: UIAlertController!
    
    /// activity indicator for loading the locations
    @IBOutlet weak var tableActivityIndicator: UIActivityIndicatorView!
    
    /// navigation item for adding a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    /// location table view
    @IBOutlet weak var locationsTableView: UITableView!

    /// add second right button
    override func viewDidLoad() {
        super.viewDidLoad()
        var postLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postLocation")
        myNavigationItem.rightBarButtonItems?.append(postLocationButton)
    }
    
    /// navigate to post location page
    func postLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        performSegueWithIdentifier("postLocation", sender: controller)
    }
    
    /// initalize alerts and table with locations
    /// :param: animated specifies whether view appears animated
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        alert = UIAlertController(title: "Error", message: "Reading student locations failed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.tableActivityIndicator.startAnimating()
        ParseClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations {
                self.locations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.locationsTableView.reloadData()
                    self.tableActivityIndicator.stopAnimating()
                }
            } else {
                println(error)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableActivityIndicator.stopAnimating()
                    self.presentViewController(self.alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    /// return number of locations (rows)
    /// :param: tableView table view
    /// :param: section section in table (there is only one)
    /// :returns: number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "LocationTableViewCell"
        let location = self.locations[indexPath.row]
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
        let location = locations[indexPath.row]
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// login button pressed
    /// :param: sender login button
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logoutButtonTouchUp()
    }
    
    /// reload button pressed
    /// :param: sender reload button
    @IBAction func reloadButtonPressed(sender: UIBarButtonItem) {
        self.locationsTableView.reloadData()
    }
    
}