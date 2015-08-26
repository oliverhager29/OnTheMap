//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

extension ParseClient {
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Key
        static let ApplicationId : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: URLs
        static let BaseURL : String = "https://api.parse.com/1/classes/StudentLocation"
        static let BaseURLSecure : String = "https://api.parse.com/1/classes/StudentLocation"
        static let AuthorizationURL : String = "https://api.parse.com/1/classes/StudentLocation"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        static let ApplicationId = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
        static let Skip = "skip"
        static let Limit = "limit"
        static let Order = "order"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        // MARK: General
        static let StatusMessage = "error"
        static let StatusCode = "code"
    }
}