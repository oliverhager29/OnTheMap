//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/21/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

struct StudentLocation {
    // an auto-generated id/key generated by Parse which uniquely identifies a StudentLocation
    var objectId: String?
    
    // an extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account (user) id
    var uniqueKey: String?
    
    // the first name of the student which matches their Udacity profile first name
    var firstName: String?
    
    // the last name of the student which matches their Udacity profile last name
    var lastName: String?
    
    // the location string used for geocoding the student location
    var mapString: String?
    
    // the URL provided by the student
    var mediaURL: String?
    
    // the latitude of the student location (ranges from -90 to 90)
    var latitude: Double?
    
    // the longitude of the student location (ranges from -180 to 180)
    var longitude: Double?

    init(objectId: String?, uniqueKey: String?, firstName: String?, lastName: String?, mapString: String?, mediaURL: String?, latitude: Double?, longitude: Double?) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(keyValuePairs: [String: AnyObject]) {
        for (key, value) in keyValuePairs {
            if(key == "objectId") {
                self.objectId = value as? String
            }
            else if(key == "uniqueKey") {
                self.uniqueKey = value as? String
            }
            else if(key == "firstName") {
                self.firstName = value as? String
            }
            else if(key == "lastName") {
                self.lastName = value as? String
            }
            else if(key == "mapString") {
                self.mapString = value as? String
            }
            else if(key == "mediaURL") {
                self.mediaURL = value as? String
            }
            else if(key == "latitude") {
                self.latitude = value as? Double
            }
            else if(key == "longitude") {
                self.longitude = value as? Double
            }
        }
    }
}