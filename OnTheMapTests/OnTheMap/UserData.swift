//
//  UserData.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 7/12/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
/// UserData - public user data of the Udacity account
class UserData {
    /// user name of the Udacity account
    var username: String
    /// user id
    var userID : String
    
    /// first name
    var firstName : String
    
    /// last name
    var lastName : String
    
    /// LinkedIn URL
    var linkedInURL : String
    
    /// email
    var email : String
    
    /// initalize fields with empty values
    init() {
        self.username = ""
        self.userID = ""
        self.firstName = ""
        self.lastName = ""
        self.linkedInURL = ""
        self.email = ""
    }
    
    /// initialize fields with passed values
    /// :param: username user name
    /// :param: userID user id
    /// :param: firstName first name
    /// :param: lastName last name
    /// :param: linkedInURL LinkedInURL
    /// :param: email email
    init(username: String, userID: String, firstName: String, lastName: String, linkedInURL: String, email: String) {
        self.username = username
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.linkedInURL = linkedInURL
        self.email = email
    }
}
