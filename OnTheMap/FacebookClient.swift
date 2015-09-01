//
//  FacebookClient.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/19/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

/// helper methods for Facebook authentication
class FacebookClient {
    class func sharedInstance() -> FacebookClient {
        
        struct Singleton {
            static var sharedInstance = FacebookClient()
        }
        
        return Singleton.sharedInstance
    }
    /// logout from facebook log in button programmatically
    func logout() {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
    }
    
    /// authenticating with Udacity using a Facebook access token
    /// :param: accessToken Facebook access token
    /// :param: completionHandler handle error/result
    func createSessionWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        //FBSession.activeSession has been replaced with [FBSDKAccessToken currentAccessToken] and FBSDKLoginManager. There is no concept of session state. Instead, use the manager to login and this sets the currentAccessToken reference.
        //Example Request:
        var body = [UdacityClient.ParameterKeys.facebookMobile : [UdacityClient.ParameterKeys.facebookAccessToken: accessToken]]
        var params : [String : AnyObject] = [:]
        UdacityClient.sharedInstance().taskForPOSTMethod(UdacityClient.Methods.CreateSession, parameters: params, jsonBody: body) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, errorString: "Facebook Login Failed.")
            }
            else if let statusMessage = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusMessage) as? String {
                completionHandler(success: false, errorString: statusMessage)
            }
            else {
                if let session: AnyObject = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) {
                    if let sessionId=session.valueForKey(UdacityClient.JSONResponseKeys.Id) as? String {
                        UdacityClient.sharedInstance().sessionID = sessionId
                        if let account: AnyObject = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) {
                                if let userId=account.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String {
                                UdacityClient.sharedInstance().userID = userId
                                completionHandler(success: true, errorString: nil)
                            }
                        }
                    }
                } else {
                    completionHandler(success: false, errorString: "Facebook Login Failed.")
                }
            }
        }
    }
}