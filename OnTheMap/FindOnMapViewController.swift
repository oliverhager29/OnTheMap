//
//  FindOnMapViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/3/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

/// FindOnMapViewController - allows user to post location onto the map
class FindOnMapViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    /// location
    var location : StudentLocation!

    /// alert window
    var alert: UIAlertController!
    
    /// posted coordinates
    var coordinates: CLLocationCoordinate2D!
    
    /// annotation for the location pin
    var pointAnnotation: MKPointAnnotation!
    
    /// activity indicator while posting location
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
    /// posted link text field
    @IBOutlet weak var linkTextField: UITextField!
    
    /// map that shows found location
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// initialize map delegate and alert window
    /// :param: animated specifies whether view appears animated
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView!.delegate = self
        alert = UIAlertController(title: "Error", message: "Posting location failed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.linkTextField!.delegate = self
        self.mapView!.addAnnotation(pointAnnotation)
        self.mapView!.centerCoordinate = coordinates
        self.mapView!.selectAnnotation(pointAnnotation, animated: true)
    }
    

    
    @IBAction func browseButtonPressed(sender: UIButton) {
        if let url = linkTextField.text {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// submit button was pressed
    /// :param: sender submit button
    @IBAction func submitButtonPressed(sender: UIButton) {
        self.mapActivityIndicator.startAnimating()
        if(self.location==nil) {
            self.alert.message = "Posting location failed: network error"
            self.alert.title = "Error"
            self.presentViewController(self.alert, animated: true, completion: nil)
        }
        else {
            self.location.mediaURL=self.linkTextField.text
            var createJSON =  "{ \"uniqueKey\" : \"\(location.uniqueKey!)\", \"firstName\" : \"\(location.firstName!)\", \"lastName\" : \"\(location.lastName!)\", \"mapString\" : \"\(location.mapString!)\", \"mediaURL\" : \"\(location.mediaURL!)\", \"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!) }"
            ParseClient.sharedInstance().createStudentLocation(createJSON)  { (result, errorString) in
                if result != nil {
                    println("Create location successful")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.mapActivityIndicator.stopAnimating()
                        println("Successful location creation with objectId \(result)")
                        self.mapActivityIndicator.stopAnimating()
                        self.alert.message = "Posting location succeeded"
                        self.alert.title = "Success"
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                        self.performSegueWithIdentifier("cancel", sender: controller)
                    })
                } else {
                    println("Posting location failed: \(errorString)")
                    dispatch_async(dispatch_get_main_queue(), {
                        println("Failed location creation")
                        self.mapActivityIndicator.stopAnimating()
                        self.alert.message = "Posting location failed: \(errorString!)"
                        self.alert.title = "Error"
                        self.presentViewController(self.alert, animated: true, completion: nil)
                    })
                }
            }
        }
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

