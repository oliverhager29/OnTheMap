//
//  StudentLocationRepository.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 8/25/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
/// class acts as repository for student locations
class StudentLocationRepository {
    static var pageIndex = 0
    static let pageSize = 10
    static var locations : [StudentLocation] = []
    
    /// get student locations with in a distance
    /// :param: fromLocation from student location
    /// :param: withInDistance distance in miles
    static func getLocations(fromLat: Double, fromLong: Double, withInDistance: Double) -> [StudentLocation] {
        var result: [StudentLocation] = []
        for location in StudentLocationRepository.locations {
            if(distance(fromLat, fromLongitude: fromLong, toLatitude: location.latitude!, toLongitude: location.longitude!) <= withInDistance) {
                result.append(location)
            }
        }
        return result
    }
    
    /// calculate distance of this student location to another student location
    /// :param: toLocation another student location
    /// :returns: distance in miles
    static func distance(fromLatitude: Double, fromLongitude: Double, toLatitude: Double, toLongitude: Double) -> Double {
        let diffLongitude = fromLongitude - toLongitude
        let diffLatitude = fromLatitude - toLatitude
        let sinLat = sin(diffLatitude/2.0)
        let sinLon = sin(diffLongitude/2)
        let a = sinLat * sinLat + cos(toLatitude) * cos(fromLatitude) * sinLon * sinLon
        let c = 2.0 * atan2( sqrt(a), sqrt(1-a) )
        //radius of earth R=3961 miles or 6373 km
        let R = 3961.0
        let d = R * c
        return d
    }
    
    static func getLocations(index: Int, activityIndicator: UIActivityIndicatorView) -> StudentLocation! {
        if(index<locations.count) {
            return locations[index]
        }
        else {
            var errorOccurred : Bool = false
            ParseClient.sharedInstance().getStudentLocations(locations.count, limit: index-(locations.count-1)+pageSize) { locations, error in
                if let locations = locations {
                    StudentLocationRepository.locations += locations
                    dispatch_async(dispatch_get_main_queue()) {
                        activityIndicator.stopAnimating()
                    }
                } else {
                    errorOccurred = true
                    println(error)
                    dispatch_async(dispatch_get_main_queue(), {
                        activityIndicator.stopAnimating()
                    })
                }
            }
            while(index >= locations.count && !errorOccurred) {
              // wait
            }
            if(index<locations.count) {
                return locations[index]
            }
            else {
                return nil
            }
        }
    }
    
    static func getLocationCount(activityIndicator: UIActivityIndicatorView) -> Int {
        var errorOccurred : Bool = false
        var numberOfLocations : Int = -1
        ParseClient.sharedInstance().getNumberOfStudentLocations() { count, error in
            if error == nil {
                errorOccurred = false
                numberOfLocations = count
                dispatch_async(dispatch_get_main_queue()) {
                    activityIndicator.stopAnimating()
                }
            } else {
                errorOccurred = true
                numberOfLocations = count
                println(error)
                dispatch_async(dispatch_get_main_queue(), {
                    activityIndicator.stopAnimating()
                })
            }
        }
        while(numberOfLocations < 0 && !errorOccurred) {
            // wait
        }
        return numberOfLocations
    }
    
    static func reset() {
        StudentLocationRepository.locations = []
        StudentLocationRepository.pageIndex = 0
    }
}