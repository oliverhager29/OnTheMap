//
//  LocationCollectionViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/29/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit

/// Meme collection view controller (handles display, addition and deletion of cells in a collection view)
class LocationCollectionViewController: UIViewController, UICollectionViewDataSource {
    /// error alert when there is a problem retrieving all locations
    var alert: UIAlertController!
    
    /// warning alert when the user tries to post its location even if a location already have been posted
    var overwriteAlert: UIAlertController!
    
    /// error alert when having a problem getting public user data of the current logged in Udacity account
    var getPublicUserDataAlert: UIAlertController!
    
    /// error alert when having a problem getting the locations of the other students
    var getStudentLocationsAlert: UIAlertController!
    
    /// user's first name
    var userFirstName : String!
    
    /// user's last name
    var userLastName : String!
    
    /// activity indicator for loading the locations
    @IBOutlet weak var collectionActivityIndicator: UIActivityIndicatorView!
    
    /// location table view
    @IBOutlet weak var locationsCollectionView: UICollectionView!
    
        /// navigation item for adding a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    /// add second right button
    override func viewDidLoad() {
        super.viewDidLoad()
        var postLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postLocation")
        myNavigationItem.rightBarButtonItems?.append(postLocationButton)
        
    }
    
    /// check whether the location for the current logged in user already has been posted and show a warning alert if so
    func checkPostLocation() {
        self.collectionActivityIndicator.startAnimating()
        if self.userFirstName != nil && self.userLastName != nil {
            ParseClient.sharedInstance().getStudentLocationsByCriteria(0, limit: 100, criteriaJSON: "{ \"firstName\" : \"\(self.userFirstName!)\", \"lastName\" : \"\(self.userLastName!)\" }") { locations, error in
                if let locations = locations {
                    if locations.count > 0 {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionActivityIndicator.stopAnimating()
                            self.presentViewController(self.overwriteAlert, animated: true, completion: nil)
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionActivityIndicator.stopAnimating()
                            self.postLocation()
                        }
                    }
                }
                else {
                    println(error)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionActivityIndicator.stopAnimating()
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
        self.collectionActivityIndicator.startAnimating()
        UdacityClient.sharedInstance().getPublicUserData()  { (result, errorString) in
            if let result = result as UserData! {
                self.userFirstName = result.firstName
                self.userLastName = result.lastName
                dispatch_async(dispatch_get_main_queue(), {
                    self.overwriteAlert = UIAlertController(title: "Error", message: "User \(self.userFirstName) \(self.userLastName) Has Already Posted a Student Location. Would You Like to Overwrite Their Location?", preferredStyle: UIAlertControllerStyle.Alert)
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
                    self.collectionActivityIndicator.stopAnimating()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionActivityIndicator.stopAnimating()
                    self.presentViewController(self.getPublicUserDataAlert, animated: true, completion: nil)
                })
            }
        }
    }

    /// return number of Memes in the collection
    /// :param: colleciton view
    /// :param: section (here only one section exists)
    /// :returns: number of Memes
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StudentLocationRepository.locations.count
    }
    
    /// fill cell with content (Memed image)
    /// :param: collection view
    /// :param: index path to cell to filled with content
    /// :returns: filled collection view cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "LocationCollectionViewCell"
        let location = StudentLocationRepository.locations[indexPath.row]
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! LocationCollectionViewCell
        
        /* Set cell defaults */
        var firstNameStr = ""
        if(location.firstName != nil) {
            firstNameStr = location.firstName!
        }
        var lastNameStr = ""
        if(location.lastName != nil) {
            lastNameStr = location.lastName!
        }
        
        var mediaURLStr = ""
        if(location.mediaURL != nil) {
            mediaURLStr = location.mediaURL!
        }
            
        cell.nameLabel!.text = "\(firstNameStr) \(lastNameStr)"
        cell.linkLabel!.text = mediaURLStr
        
        return cell
    }
    
    /// dismiss current page (login page will be re-displayed)
    func logoutButtonTouchUp() {
        self.collectionActivityIndicator.startAnimating();
        UdacityClient.sharedInstance().deleteSession() { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionActivityIndicator.stopAnimating()
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
        //self.locationCollectionView.reloadData()
    }

}