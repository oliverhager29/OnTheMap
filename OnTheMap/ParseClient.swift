//
//  ParseClient.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    var config = ParseConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /// Send an HTTP GET request and handle then JSON response
    /// :param: method REST operation
    /// :param: parameters request parameters
    /// :param: jsonBody JSON body of request
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + ParseClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if(data ==  nil || data.length<5) {
                let userInfo = [NSLocalizedDescriptionKey : "No connectivity"]
                completionHandler(result: nil, error: NSError(domain: "Parse Error", code: 1, userInfo: userInfo))
            }
            else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                if let error = downloadError {
                    let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
                } else {
                    ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /// Send an HTTP POST request and handle then JSON response
    /// :param: method REST operation
    /// :param: parameters request parameters
    /// :param: jsonBody JSON body of request
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + ParseClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if(data ==  nil || data.length<5) {
                let userInfo = [NSLocalizedDescriptionKey : "No connectivity"]
                completionHandler(result: nil, error: NSError(domain: "Parse Error", code: 1, userInfo: userInfo))
            }
            else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                if let error = downloadError {
                    let newError = ParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
                } else {
                    ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /// Send an HTTP DELETE request and handle then JSON response
    /// :param: method REST operation
    /// :param: parameters request parameters
    /// :param: jsonBody JSON body of request
    func taskForDELETEMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + ParseClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if(data ==  nil || data.length<5) {
                let userInfo = [NSLocalizedDescriptionKey : "No connectivity"]
                completionHandler(result: nil, error: NSError(domain: "Parse Error", code: 1, userInfo: userInfo))
            }
            else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                if let error = downloadError {
                    let newError = ParseClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: downloadError)
                } else {
                    ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[ParseClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Parse Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}