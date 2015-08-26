//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//


import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension ParseClient {
    /// get student locations
    /// :param: completionHandler handles error/result
    func getStudentLocations(skip: Int, limit: Int, completionHandler: (result: [StudentLocation]?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Constants.BaseURL+"?\(ParseClient.ParameterKeys.Limit)=\(limit)&\(ParseClient.ParameterKeys.Skip)=\(skip)&\(ParseClient.ParameterKeys.Order)=\(ParseClient.JSONResponseKeys.FirstName),\(ParseClient.JSONResponseKeys.LastName)")!)
        request.addValue(ParseClient.Constants.ApplicationId, forHTTPHeaderField: ParseClient.ParameterKeys.ApplicationId)
        request.addValue(ParseClient.Constants.ApiKey, forHTTPHeaderField: ParseClient.ParameterKeys.ApiKey)
        
        request.addValue(skip.description, forHTTPHeaderField: ParseClient.ParameterKeys.Skip)
        request.addValue(limit.description, forHTTPHeaderField: ParseClient.ParameterKeys.Limit)
        request.addValue("\(ParseClient.ParameterKeys.Order)=\(ParseClient.JSONResponseKeys.FirstName),\(ParseClient.JSONResponseKeys.LastName)", forHTTPHeaderField: ParseClient.ParameterKeys.Order)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                 completionHandler(result: [], errorString: "Getting Student Locations failed with network error \(error.description)")
            }
            else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                var parsingError: NSError? = nil
                
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let error = parsingError {
                    completionHandler(result: [], errorString: "Getting Student Locations failed with parsing error \(error.description)")
                }
                else if let statusMessage = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String {
                    completionHandler(result: [], errorString: "Getting Student Locations failed with error \(statusMessage)")
                }
                else {
                    var studentLocations : [StudentLocation] = []
                    if let locations = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.Results) as? [AnyObject] {
                        for location in locations {
                            let objectId = location.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String
                            let uniqueKey = location.valueForKey(ParseClient.JSONResponseKeys.UniqueKey) as? String
                            let firstName = location.valueForKey(ParseClient.JSONResponseKeys.FirstName) as? String
                            let lastName = location.valueForKey(ParseClient.JSONResponseKeys.LastName) as? String
                            let mapString = location.valueForKey(ParseClient.JSONResponseKeys.MapString) as? String
                            let mediaURL = location.valueForKey(ParseClient.JSONResponseKeys.MediaURL) as? String
                            let latitude = location.valueForKey(ParseClient.JSONResponseKeys.Latitude) as? Double
                            let longitude = location.valueForKey(ParseClient.JSONResponseKeys.Longitude) as? Double
                            var studentLocation = StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
                            studentLocations.append(studentLocation)
                        }
                    }
                    completionHandler(result: studentLocations, errorString: nil)
                }
                return
            }
        }
        task.resume()
    }
    
    /// get student location by criteria
    /// :param: criteriaJSON criteria as JSON key/value pairs
    /// :param: completionHandler handles error/result
    func getStudentLocationsByCriteria(skip: Int, limit: Int, criteriaJSON: String, completionHandler: (result: [StudentLocation]?, errorString: String?) -> Void) {
        var tmpStr : String? = criteriaJSON.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        if let criteriaJSONEscaped = tmpStr {
            let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Constants.BaseURL+ParseClient.Constants.BaseURL+"?\(ParseClient.ParameterKeys.Limit)=\(limit)&\(ParseClient.ParameterKeys.Skip)=\(skip)&\(ParseClient.ParameterKeys.Order)=\(ParseClient.JSONResponseKeys.FirstName),\(ParseClient.JSONResponseKeys.LastName)&where="+criteriaJSONEscaped)!)
            request.addValue(ParseClient.Constants.ApplicationId, forHTTPHeaderField: ParseClient.ParameterKeys.ApplicationId)
            request.addValue(ParseClient.Constants.ApiKey, forHTTPHeaderField: ParseClient.ParameterKeys.ApiKey)
            request.addValue(skip.description, forHTTPHeaderField: ParseClient.ParameterKeys.Skip)
            request.addValue(limit.description, forHTTPHeaderField: ParseClient.ParameterKeys.Limit)
            request.addValue("order=\(ParseClient.JSONResponseKeys.FirstName),l\(ParseClient.JSONResponseKeys.LastName)", forHTTPHeaderField: ParseClient.ParameterKeys.Order)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    completionHandler(result: [], errorString: "Getting Student Locations By Criteria failed with network error \(error.description)")
                }
                else {
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    var parsingError: NSError? = nil
                
                    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                    if let error = parsingError {
                        completionHandler(result: nil, errorString: "Getting Student Locations By Criteria failed with network error \(error.description)")
                    }
                    else if let statusMessage = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String {
                        completionHandler(result: [], errorString: "Getting Student Locations By Criteria failed with error \(statusMessage)")
                    }
                    else {
                        var studentLocations : [StudentLocation] = []
                        if let locations = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.Results) as? [AnyObject] {
                            for location in locations {
                                let objectId = location.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String
                                let uniqueKey = location.valueForKey(ParseClient.JSONResponseKeys.UniqueKey) as? String
                                let firstName = location.valueForKey(ParseClient.JSONResponseKeys.FirstName) as? String
                                let lastName = location.valueForKey(ParseClient.JSONResponseKeys.LastName) as? String
                                let mapString = location.valueForKey(ParseClient.JSONResponseKeys.MapString) as? String
                                let mediaURL = location.valueForKey(ParseClient.JSONResponseKeys.MediaURL) as? String
                                let latitude = location.valueForKey(ParseClient.JSONResponseKeys.Latitude) as? Double
                                let longitude = location.valueForKey(ParseClient.JSONResponseKeys.Longitude) as? Double
                                var studentLocation = StudentLocation(objectId: objectId, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
                                studentLocations.append(studentLocation)
                            }
                        }
                        completionHandler(result: studentLocations, errorString: nil)
                    }
                }
                return
            }
            task.resume()
        }
    }
    
    /// create student location
    /// :param: createJSON JSON key/value pairs specify data of the new student location
    func createStudentLocation(createJSON: String, completionHandler: (result: String?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Constants.BaseURL)!)
        request.addValue(ParseClient.Constants.ApplicationId, forHTTPHeaderField: ParseClient.ParameterKeys.ApplicationId)
        request.addValue(ParseClient.Constants.ApiKey, forHTTPHeaderField: ParseClient.ParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = createJSON.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(result: nil, errorString: "Creating Student Location failed with network error \(error.description)")
            }
            else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                println("createLocation response:\(NSString(data: data, encoding: NSUTF8StringEncoding))")
                var parsingError: NSError? = nil
                
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let error = parsingError {
                    completionHandler(result: nil, errorString: "Creating Student Location failed with parsing error \(error.description)")
                }
                else if let statusMessage = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String {
                    completionHandler(result: nil, errorString: "Creating Student Location failed with error \(statusMessage)")
                }
                else {
                    if let objectId = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String {
                        
                        completionHandler(result: objectId, errorString: nil)
                    }
                }
            }
            return
        }
        task.resume()
    }

    /// create student location
    /// :param: createJSON JSON key/value pairs specify data of the new student location
    func updateStudentLocation(objectId: String, updateJSON: String, completionHandler: (result: Bool, errorString: String?) -> Void) {
            let request = NSMutableURLRequest(URL: NSURL(string: ParseClient.Constants.BaseURL+"/"+objectId)!)
            request.addValue(ParseClient.Constants.ApplicationId, forHTTPHeaderField: ParseClient.ParameterKeys.ApplicationId)
            request.addValue(ParseClient.Constants.ApiKey, forHTTPHeaderField: ParseClient.ParameterKeys.ApiKey)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPMethod = "PUT"
            request.HTTPBody = updateJSON.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    completionHandler(result: false, errorString: "Modifying Student Location failed with network error \(error.description)")
                }
                else {
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    println("modifyLocation response:\(NSString(data: data, encoding: NSUTF8StringEncoding))")
                    var parsingError: NSError? = nil
                    
                    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                    
                    if let error = parsingError {
                        completionHandler(result: false, errorString: "Modifying Student Location failed with parsing error \(error.description)")
                    }
                    else if let statusMessage = parsedResult?.valueForKey(ParseClient.JSONResponseKeys.StatusMessage) as? String {
                        completionHandler(result: false, errorString: "Modifying Student Location failed with error \(statusMessage)")
                    }
                    else {
                        completionHandler(result: true, errorString: nil)
                    }
                }
                return
            }
            task.resume()
    }
}