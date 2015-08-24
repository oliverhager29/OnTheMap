//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//


import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    
    /// create Udacity session (login)
    /// :param: username user name i.e. email of Udacity account
    /// :param: password passowrd of Udacity account
    /// :param: completionHandler returns error/result
    func createSession(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        var body = ["udacity" : [ParameterKeys.UserName: username, UdacityClient.ParameterKeys.Password : password]]
        var params : [String : AnyObject] = [:]
        taskForPOSTMethod(Methods.CreateSession, parameters: params, jsonBody: body) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorString: "Login Failed because of a network problem.")
            }
            if let statusMessage = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusMessage) as? String {
                completionHandler(success: false, errorString: statusMessage)
            }
            else {
                if let session = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) {
                    if let sessionID = session.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                        if let account = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) {
                            if let userID = account.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String {
                                    self.userID = userID
                                    completionHandler(success: true, errorString: nil)
                            }
                        }
                    }
                    else {
                        completionHandler(success: false, errorString: "Login Failed.")
                    }
                }
            }
        }
    }
    
    /// delete Udacity session (logout) of current logged in Udacity account
    /// :param: completionHandler returns error/result
    func deleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        var params : [String : AnyObject] = [:]
        var headerParams : [String : AnyObject] = [:]
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
           headerParams.updateValue(xsrfCookie.value!, forKey: "X-XSRF-Token")
        }
        taskForDELETEMethod(Methods.DeleteSession, parameters: params, headerParameters: headerParams) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorString: "Logout failed.")
            }
            if let statusMessage = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusMessage) as? String {
                completionHandler(success: false, errorString: statusMessage)
            }
            else {
                if let sessionID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Logout Failed.")
                }
            }
        }
    }
    
    /// get public user data of Udacity account
    /// :param: completionHandler returns error/result
    func getPublicUserData(completionHandler: (result: UserData?, errorString: String?) -> Void) {
        var params : [String : AnyObject] = [:]
        taskForGETMethod(Methods.GetPublicUserData+"/\(userID!)", parameters: params) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, errorString: "Get User Data Failed.")
            }
            if let statusMessage = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusMessage) as? String {
                completionHandler(result: nil, errorString: statusMessage)
            }
            else {
                if let user = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) {
                    let userData = UserData()
                    if let username = user.valueForKey(UdacityClient.JSONResponseKeys.User) as? String {
                        userData.username = username
                    }
                    if let userID = user.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String {
                        userData.userID = userID
                    }
                    if let firstName = user.valueForKey(UdacityClient.JSONResponseKeys.FirstName) as? String {
                        userData.firstName = firstName
                    }
                    if let lastName = user.valueForKey(UdacityClient.JSONResponseKeys.LastName) as? String {
                        userData.lastName = lastName
                    }
                    if let linkedInURL = user.valueForKey(UdacityClient.JSONResponseKeys.LinkedInURL) as? String {
                        userData.linkedInURL = linkedInURL
                    }
                    if let email = user.valueForKey(UdacityClient.JSONResponseKeys.Email) {
                        if let address = email.valueForKey(UdacityClient.JSONResponseKeys.Address) as? String {
                        userData.email = address
                        }
                    }
                    completionHandler(result: userData, errorString: nil)
                }
            }
        }
    }
    
    /*
    POSTing (Creating) a Session with Facebook Authentication
    
    Method: https://www.udacity.com/api/session
    Method Type: POST
    Udacity Facebook App ID = 365362206864879
    Required Parameters:
    facebook_mobile - (Dictionary) a dictionary containing an access token from a valid Facebook session
    access_token - (String) the user access token from Facebook
    an access token is made available through the FBSDKAccessToken class
    Note: the Facebook SDK was recently updated to version 4.0. According to the upgrade guide:
    */
    func createSessionWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        //FBSession.activeSession has been replaced with [FBSDKAccessToken currentAccessToken] and FBSDKLoginManager. There is no concept of session state. Instead, use the manager to login and this sets the currentAccessToken reference.
        //Example Request:
        var body = [ParameterKeys.facebookMobile : [ParameterKeys.facebookAccessToken: accessToken]]
        var params : [String : AnyObject] = [:]
        taskForPOSTMethod(Methods.CreateSession, parameters: params, jsonBody: body) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorString: "Facebook Login Failed.")
            }
            else if let statusMessage = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusMessage) as? String {
                completionHandler(success: false, errorString: statusMessage)
            }
            else {
                if let sessionID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.SessionID) as? String {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Facebook Login Failed.")
                }
            }
        }
    }
}