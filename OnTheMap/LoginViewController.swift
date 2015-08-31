//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/1/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
/// LoginViewController - login page
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    /// failed login alert
    var failedLoginAlert: UIAlertController!
    
    /// logo
    @IBOutlet weak var logoImageView: UIImageView!
    
    /// user/email text field
    @IBOutlet weak var emailTextField: UITextField!

    /// password text field
    @IBOutlet weak var passwordTextField: UITextField!
    
    /// login button
    @IBOutlet weak var loginButton: UIButton!

    /// sign up Udacity account button
    @IBOutlet weak var signUpButton: UIButton!
    
    /// activity indicator while logging in
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    /// login button pressed
    /// :param: sender login button
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.login(emailTextField.text, password: passwordTextField.text)
    }
    
    /// sign-up button pressed
    /// :param: sender sign-up button
    @IBAction func signUpButtonPressed(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            FacebookClient.sharedInstance().createSessionWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString!){ (success, errorString) in
                if success {
                    println("Login successful")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.completeLogin()
                    })
                    
                } else {
                    let tmpErrorString = errorString
                    println("Login failed: \(tmpErrorString)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayError(tmpErrorString)
                    })
                    FacebookClient.sharedInstance().logout()
                }
            }
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            let loginViewWidth = loginView.frame.width
            let loginViewHeight = loginView.frame.height
            loginView.center.x = self.view.center.x
            loginView.center.y = self.view.center.y + self.emailTextField.frame.height + self.passwordTextField.frame.height + self.loginButton.frame.height + self.signUpButton.frame.height + 4 * 8 + loginViewHeight / 2
            self.view.addSubview(loginView)
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }

    /// initialize failed login alert with a "finger" animation
    override func viewWillAppear(animated: Bool) {
        failedLoginAlert = UIAlertController(title: "Error", message: "Invalid Email or Password", preferredStyle: UIAlertControllerStyle.Alert)
        failedLoginAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        var imageView = UIImageView(frame: CGRectMake(220, 10, 40, 40))
        imageView.image = UIImage.animatedImageNamed("shake", duration: 1)
        imageView.startAnimating()
        self.failedLoginAlert.view.addSubview(imageView)
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    /// Facebook login
    /// :param: loginButton Facebook login button
    /// :param: result login result
    /// :param: error login error
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            self.displayError(error.description)
        }
        else if result.isCancelled {
            // Handle cancellations
            
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                FacebookClient.sharedInstance().createSessionWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString!){ (success, errorString) in
                    if success {
                        println("Login successful")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.completeLogin()
                        })
                        
                    } else {
                        let tmpErrorString = errorString
                        println("Login failed: \(tmpErrorString)")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayError(tmpErrorString)
                        })
                    }
                }
            }
        }
    }
    
    /// Facebook logout
    /// :param: loginButton Facebook login button
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
        self.loginActivityIndicator.startAnimating()
        UdacityClient.sharedInstance().deleteSession() { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                self.loginActivityIndicator.stopAnimating()
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
    
    /// perform login (create UDacity session)
    /// :param: username user name
    /// :param: password password
    func login(username: String, password: String) -> Void {
        self.loginActivityIndicator.startAnimating()
        UdacityClient.sharedInstance().createSession(username, password: password)  { (success, errorString) in
            if success {
                println("Login successful")
                dispatch_async(dispatch_get_main_queue(), {
                    self.completeLogin()
                })
                
            } else {
                println("Login failed: \(errorString)")
                self.displayError(errorString)
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.loginActivityIndicator.stopAnimating()
            })
        }
    }
    
    /// successfully completed login and navigates to the page that show all users' locations
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    ///login failed
    /// :param: errorString error message
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                dispatch_async(dispatch_get_main_queue(), {
                    self.failedLoginAlert!.message = errorString
                    self.presentViewController(self.failedLoginAlert, animated: true, completion: nil)
                    
                })
            }
        })
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