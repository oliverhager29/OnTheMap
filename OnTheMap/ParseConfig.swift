//
//  ParseConfig.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//

import Foundation

private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("TheMovieDB-Context")

// MARK: - Config Class

class ParseConfig: NSObject, NSCoding {
    
    /* Default values from 1/12/15 */
    var dateUpdated: NSDate? = nil
    
    // MARK: - Initialization
    
    override init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()    }
    
    // MARK: - Update

    func updateConfiguration() {
        /*
        ParseClient.sharedInstance().getConfig() { didSucceed, error in
            
            if let error = error {
                println("Error updating config: \(error.localizedDescription)")
            } else {
                println("Updated Config: \(didSucceed)")
                self.save()
            }
        } */
    }
    
    // MARK: - NSCoding
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
}
