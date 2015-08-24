//
//  UdacityConfig.swift
//  OnTheMap
//
//  Created by OLIVER HAGER on 6/9/15.
//  Copyright (c) 2015 OLIVER HAGER. All rights reserved.
//
import Foundation

private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("Udacity-Context")

// MARK: - Config Class

class UdacityConfig: NSObject, NSCoding {
    var dateUpdated: NSDate? = nil
    
    /* Returns the number days since the config was last updated */
    var daysSinceLastUpdate: Int? {
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
        } else {
            return nil
        }
    }
    
    // MARK: - Initialization
    override init() {}
    
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
    }
    
    // MARK: - Update
    func updateIfDaysSinceUpdateExceeds(days: Int) {
        // If the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        }
        else {
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        /*UdacityClient.sharedInstance().getConfig() { didSucceed, error in
            
            if let error = error {
                println("Error updating config: \(error.localizedDescription)")
            } else {
                println("Updated Config: \(didSucceed)")
                self.save()
            }
        }*/
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
    
    class func unarchivedInstance() -> UdacityConfig? {
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? UdacityConfig
        }
        else {
            return nil
        }
    }
}
