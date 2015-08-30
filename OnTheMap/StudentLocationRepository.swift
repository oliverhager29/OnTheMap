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
    static let pageSize = 100
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
}