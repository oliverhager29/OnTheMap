//
//  TestViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 7/12/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var queryCriteria: UITextField!
    @IBOutlet weak var facebookAccessToken: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameTextField.text = "oli484@googlemail.com"
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.login(usernameTextField.text, password: passwordTextField.text)
    }
    
    @IBAction func facebookLoginButtonPressed(sender: UIButton) {
        facebookLogin(facebookAccessToken.text)
    }
    
    @IBAction func getUserDataButtonPressed(sender: UIButton) {
        self.getUserData()
    }
    
    @IBAction func getLocationButtonPressed(sender: UIButton) {
        getStudentLocations()
    }
    
    @IBAction func queryLocationButtonPressed(sender: UIButton) {
        queryStudentLocations()
    }
    
    @IBAction func createLocationPressed(sender: UIButton) {
        createLocation()
    }
    
    @IBAction func updateLocationPressed(sender: UIButton) {
        updateLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(username: String, password: String) -> Void {
        let outputTextView = self.outputTextView
        UdacityClient.sharedInstance().createSession(username, password: password)  { (success, errorString) in
            if success {
                println("Login successful")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Successful login"
                })

            } else {
                println("Login failed: \(errorString)")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Failed login"
                })
            }
        }
    }
    
    func facebookLogin(accessToken: String) -> Void {
        let outputTextView = self.outputTextView
        UdacityClient.sharedInstance().createSessionWithFacebook(accessToken)  { (success, errorString) in
            if success {
                println("Login successful")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Successful login"
                })
                
            } else {
                println("Login failed: \(errorString)")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Failed login"
                })
            }
        }
    }
    
    func getUserData() -> Void {
        let outputTextView = self.outputTextView
        UdacityClient.sharedInstance().getPublicUserData()  { (result, errorString) in
            if(result != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Successful get user data - username: \(result!.username), user id: \(result!.userID), first name: \(result!.firstName), last name: \(result!.lastName), email: \(result!.email), linked in url: \(result!.linkedInURL)"
                })
            } else {
                println("Login failed: \(errorString)")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Failed get user data"
                })
            }
        }
    }
    
    func getStudentLocations() -> Void {
        let outputTextView = self.outputTextView
        ParseClient.sharedInstance().getStudentLocations(0, limit: 100) { (result, errorString) -> Void in
            if(errorString != nil) {
                println("getStudentLocation failed: \(errorString)")
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    println("getStudentLocation successful")
                    var str = ""
                    for location in result! {
                        str += "First name: \(location.firstName), Last name: \(location.lastName), Linkin URL: \(location.mediaURL), Map string: \(location.mapString)"
                    }
                    outputTextView.text = str
                })
            }
        }
    }
    
    func queryStudentLocations() -> Void {
        let outputTextView = self.outputTextView
        ParseClient.sharedInstance().getStudentLocationsByCriteria(0, limit: 100, criteriaJSON: queryCriteria.text) { (result, errorString) -> Void in
            if(errorString != nil) {
                println("getStudentLocation failed: \(errorString)")
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    println("getStudentLocationsByCriteria successful")
                    var str = ""
                    for location in result! {
                        str += "First name: \(location.firstName), Last name: \(location.lastName), Linkin URL: \(location.mediaURL), Map string: \(location.mapString)"
                    }
                    outputTextView.text = str
                })
            }
        }
    }

    func createLocation() -> Void {
        var createJSON =  "{ \"uniqueKey\" : \"test0815\", \"firstName\" : \"Olitestfn1\", \"lastName\" : \"Olitestln1\", \"mapString\" : \"Georgia\", \"mediaURL\" : \"http://www.test.com\", \"latitude\": 37.386052, \"longitude\": -122.083851 }"
        let outputTextView = self.outputTextView
        ParseClient.sharedInstance().createStudentLocation(createJSON)  { (result, errorString) in
            if result != nil {
                println("Create location successful")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Successful location creation with objectId \(result)"
                })
            
            } else {
                println("Create location failed: \(errorString)")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Failed location creation"
                })
            }
        }
    }
    
    func updateLocation() -> Void {
        let updateJSON = "{ \"firstName\" : \"Changedtestfn1\" }"
        let objectId = "DTG7OiTtOy"
        let outputTextView = self.outputTextView
        ParseClient.sharedInstance().updateStudentLocation(objectId, updateJSON: updateJSON)  { (success, errorString) in
            if success {
                println("Update location successful")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Successful location update"
                })
                
            } else {
                println("Update location failed: \(errorString)")
                dispatch_async(dispatch_get_main_queue(), {
                    outputTextView.text = "Failed location update"
                })
            }
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
}