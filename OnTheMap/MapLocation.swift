//
//  MapLocation
//  OnTheMap
//
//  Created by OLIVER HAGER on 7/5/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import MapKit

class MapLocation: NSObject, MKAnnotation {
    let title: String
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let mediaURL: String
    init(title: String, locationName: String, mediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.mediaURL = mediaURL
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return mediaURL
    }
}