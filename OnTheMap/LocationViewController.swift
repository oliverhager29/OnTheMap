//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/16/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// LocationViewController - this page allows the current logged in user to lookup its location and navigate to the posting location page. The user may decide to cancel the posting and return to the previous page (map or table of locations)
class LocationViewController: UIViewController, UITextFieldDelegate {
    
    /// error alert when retrieving the public data of the currently logged in user
    var getPublicUserDataAlert: UIAlertController!
    
    /// error alert when getting a location for the location string (map string)
    var geoCodingAlert: UIAlertController!
    
    /// location
    var location : StudentLocation!
    
    /// posted coordinates
    var coordinates: CLLocationCoordinate2D!
    
    /// annotation for the location pin
    var pointAnnotation: MKPointAnnotation!
    
    /// activity indicator when looking up the location for a location string
    /// "Where are you studying today?" labels
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    /// find on the map button
    @IBOutlet weak var findOnTheMapButton: UIButton!
    /// text field for the location string
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// cancel button pressed
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// find on map button pressed
    /// :param: sender find on map button
    @IBAction func findOnMap(sender: UIButton) {
        self.startActivityIndicator()
        
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationTextField.text, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil || placemarks == nil || placemarks.count == 0){
                println("Error", error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                    self.presentViewController(self.geoCodingAlert, animated: true, completion: nil)
                })
            }
            else if let placemark = placemarks?[0] as? CLPlacemark {
                var placemark:CLPlacemark = placemarks[0] as! CLPlacemark
                var coordinates:CLLocationCoordinate2D = placemark.location.coordinate
                
                var pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                UdacityClient.sharedInstance().getPublicUserData()  { (result, errorString) in
                    if(result != nil) {
                        pointAnnotation.title = "\(result!.firstName) \(result!.lastName)"
                        self.location = StudentLocation(objectId: result!.userID, uniqueKey: result!.userID, firstName: result!.firstName, lastName: result!.lastName, mapString: self.locationTextField.text, mediaURL: result!.linkedInURL, latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
                        self.coordinates = coordinates
                        self.pointAnnotation = pointAnnotation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stopActivityIndicator()
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FindOnMapViewController") as! FindOnMapViewController
                            self.performSegueWithIdentifier("findOnMap", sender: controller)
                        })
                    }
                    else {
                        println("Get public user data failed: \(errorString)")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.stopActivityIndicator()
                            self.presentViewController(self.getPublicUserDataAlert, animated: true, completion: nil)
                        })
                    }
                }
            }
        })
    }
    
    /// initialize alerts
    /// :param: animated specifies whether view appears animated
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getPublicUserDataAlert = UIAlertController(title: "Error", message: "Getting public user data failed", preferredStyle: UIAlertControllerStyle.Alert)
        getPublicUserDataAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        geoCodingAlert = UIAlertController(title: "Error", message: "Looking up the location failed", preferredStyle: UIAlertControllerStyle.Alert)
        geoCodingAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.locationTextField!.delegate = self
    }
    
    /// find location for location string and navigate to posting location page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "findOnMap") {
            if let controller = segue.destinationViewController as? FindOnMapViewController {
                controller.location = self.location
                controller.coordinates = self.coordinates
                controller.pointAnnotation = self.pointAnnotation
            }
        }
    }
    
    /// start activity indicator
    func startActivityIndicator() {
        self.locationActivityIndicator.startAnimating()
        self.label1.alpha = 0.5
        self.label2.alpha = 0.5
        self.label3.alpha = 0.5
        self.locationTextField.alpha = 0.5
        self.findOnTheMapButton.alpha = 0.5
    }
    
    /// stop activity indicator
    func stopActivityIndicator() {
        self.locationActivityIndicator.stopAnimating()
        self.label1.alpha = 1.0
        self.label2.alpha = 1.0
        self.label3.alpha = 1.0
        self.locationTextField.alpha = 1.0
        self.findOnTheMapButton.alpha = 1.0
    }
    
    /// hides text field after return
    /// textField text field
    /// :returns: true
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
}