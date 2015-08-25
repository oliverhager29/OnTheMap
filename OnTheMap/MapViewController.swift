//
//  MapViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 7/5/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// MapViewController - map that shows the locations of the other students
class MapViewController: UIViewController,MKMapViewDelegate {
    /// error alert when having a problem getting public user data of the current logged in Udacity account
    var getPublicUserDataAlert: UIAlertController!
    
    /// error alert when having a problem getting the locations of the other students
    var getStudentLocationsAlert: UIAlertController!
    
    /// warning alert when the user tries to post its location even if a location already have been posted
    var overwriteAlert: UIAlertController!
    
    /// user's first name
    var userFirstName : String!
    
    /// user's last name
    var userLastName : String!
    
    /// activity indicator for loading the locations
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
    /// navigation item to enhance for a second right button
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    /// map for showing the other student's locations
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var postLocationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "checkPostLocation")
        myNavigationItem.rightBarButtonItems?.append(postLocationButton)
    }
    
    /// check whether the location for the current logged in user already has been posted and show a warning alert if so
    func checkPostLocation() {
        self.mapActivityIndicator.startAnimating()
        if self.userFirstName != nil && self.userLastName != nil {
            ParseClient.sharedInstance().getStudentLocationsByCriteria("{ \"firstName\" : \"\(self.userFirstName!)\", \"lastName\" : \"\(self.userLastName!)\" }") { locations, error in
                if let locations = locations {
                    if locations.count > 0 {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapActivityIndicator.stopAnimating()
                            self.presentViewController(self.overwriteAlert, animated: true, completion: nil)
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapActivityIndicator.stopAnimating()
                            self.postLocation()
                        }
                    }
                }
                else {
                    println(error)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mapActivityIndicator.stopAnimating()
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
    
    /// initialize the alerts and their handlers
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getStudentLocationsAlert = UIAlertController(title: "Error", message: "Reading student locations failed", preferredStyle: UIAlertControllerStyle.Alert)
        self.getStudentLocationsAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.getPublicUserDataAlert = UIAlertController(title: "Error", message: "Getting public user data failed", preferredStyle: UIAlertControllerStyle.Alert)
        self.getPublicUserDataAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.mapActivityIndicator.startAnimating()
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
                    self.mapActivityIndicator.stopAnimating()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapActivityIndicator.stopAnimating()
                    self.presentViewController(self.getPublicUserDataAlert, animated: true, completion: nil)
                })
            }
        }
        if StudentLocationRepository.locations.count == 0 {
            reloadLocations()
        }
        else {
            addAnnotations(self.mapView, locations: StudentLocationRepository.locations)
        }
    }
    
    /// add annotations to map
    /// :param: mapview map view
    /// :patam: locations for which annotations are created
    func addAnnotations(mapView: MKMapView!, locations: [StudentLocation]) {
        for location in locations {
            if location.latitude != nil && location.longitude != nil {
                var locationName = ""
                if location.mapString != nil {
                    locationName = location.mapString!
                }
                var firstName = ""
                if location.firstName != nil {
                    firstName = location.firstName!
                }
                var lastName = ""
                if location.lastName != nil {
                    lastName = location.lastName!
                }
                let mapLocation = MapLocation(title: "\(firstName) \(lastName)",
                    locationName: locationName,
                    coordinate: CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!))
                mapView.addAnnotation(mapLocation)
            }
        }
    }
    
    /// reload the other students locations (refresh button is pressed)
    func reloadLocations() {
        dispatch_async(dispatch_get_main_queue(), {
            self.mapActivityIndicator.startAnimating()
            
        })
        ParseClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations {
                StudentLocationRepository.locations = locations
                dispatch_async(dispatch_get_main_queue()) {
                    self.addAnnotations(self.mapView, locations: locations)
                    self.mapView.delegate = self
                    self.mapActivityIndicator.stopAnimating()
                }
            } else {
                println(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapActivityIndicator.stopAnimating()
                    self.presentViewController(self.getStudentLocationsAlert, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// create/retrieve view with pin and annotation for a location in the map
    /// :param: mapView map
    /// :param annotation annotation for the location
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MapLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    /// logout button pressed
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logoutButtonTouchUp()
    }
    
    /// delete Udacity session and dismiss current page
    func logoutButtonTouchUp() {
        self.mapActivityIndicator.startAnimating();
        UdacityClient.sharedInstance().deleteSession() { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                self.mapActivityIndicator.stopAnimating()
            })
            if success {
                println("Logout successful")
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                })
            }
            else {
                println("Logout failed: \(errorString)")
            }
        }
    }
    
    /// reload button pressed
    /// :param: sender reload button
    @IBAction func reloadButtonPressed(sender: UIBarButtonItem) {
        reloadLocations()
    }
    
    /// center map around users current location
    /// :param mapView map
    /// :param: userLocation user's current location
    func mapView(mapView: MKMapView!, didUpdateUserLocation
        userLocation: MKUserLocation!) {
            mapView.centerCoordinate = userLocation.location.coordinate
    }
}
