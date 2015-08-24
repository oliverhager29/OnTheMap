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
class LocationViewController: UIViewController {
    
    /// error alert when retrieving the public data of the currently logged in user
    var getPublicUserDataAlert: UIAlertController!
    
    /// error alert when getting a location for the location string (map string)
    var geoCodingAlert: UIAlertController!
    
    /// activity indicator when looking up the location for a location string
    @IBOutlet weak var locationActivityIndicator: UIActivityIndicatorView!
    
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
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FindOnMapViewController") as! FindOnMapViewController
        performSegueWithIdentifier("findOnMap", sender: controller)
    }
    
    /// initialize alerts
    /// :param: animated specifies whether view appears animated
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getPublicUserDataAlert = UIAlertController(title: "Error", message: "Getting public user data failed", preferredStyle: UIAlertControllerStyle.Alert)
        getPublicUserDataAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        geoCodingAlert = UIAlertController(title: "Error", message: "Getting public user data failed", preferredStyle: UIAlertControllerStyle.Alert)
        geoCodingAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    /// find location for location string and navigate to posting location page
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "findOnMap") {
            if let controller = segue.destinationViewController as? FindOnMapViewController {
                dispatch_async(dispatch_get_main_queue(), {
                    self.locationActivityIndicator.startAnimating()
                })

                var geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(locationTextField.text, completionHandler: {(placemarks, error) -> Void in
                    if((error) != nil){   
                        println("Error", error)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.locationActivityIndicator.stopAnimating()
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
                                controller.location = StudentLocation(objectId: result!.userID, uniqueKey: result!.userID, firstName: result!.firstName, lastName: result!.lastName, mapString: self.locationTextField.text, mediaURL: result!.linkedInURL, latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.locationActivityIndicator.stopAnimating()
                                    controller.mapView?.addAnnotation(pointAnnotation)
                                    controller.mapView?.centerCoordinate = coordinates
                                    controller.mapView?.selectAnnotation(pointAnnotation, animated: true)
                                })
                            }
                            else {
                                pointAnnotation.title = ""
                                println("Get public user data failed: \(errorString)")
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.locationActivityIndicator.stopAnimating()
                                    self.presentViewController(self.getPublicUserDataAlert, animated: true, completion: nil)
                                })
                            }
                        }
                    }
                })
            }
        }
    }
}