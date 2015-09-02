//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

/// constants used by Udacity API
extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "122c095bfd7244a509e4fc7d87e4113d"
        
        // MARK: URLs
        static let BaseURL : String = "https://www.udacity.com/api/"
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let AuthorizationURL : String = "https://www.udacity.com/api/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        // Udacity API
        static let CreateSession = "session"
        static let DeleteSession = "session"
        static let GetPublicUserData = "users"
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        static let UserID = "userId"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let UserId = "userId"
        static let UserName = "username"
        static let Password = "password"
        
        static let facebookMobile = "facebook_mobile"
        static let facebookAccessToken = "access_token"
        
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Session = "session"
        static let Key = "key"
        static let Id = "id"
        static let Expiration = "expiration"
        
        static let User = "user"
        static let socialAccounts = "social_accounts"
        static let MailingAddress = "mailing_address"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let LinkedInURL = "linkedin_url"
        static let Email = "email"
        static let Address = "address"
        
        
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "status"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
    }
}