//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by john bateman on 7/25/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  This file implements the StudentLocation class which describes a unique student location consisting of gps coordinates, the student's name, and other metadata.

import Foundation

struct StudentLocation {
    
    var objectId = ""   // Parse object Id
    var uniqueKey = ""  // Udacity account or Facebook (user) id
    var firstName = ""  // first name of student
    var lastName = ""   // last name of student
    var mapString = ""  // text description of location
    var mediaURL = ""   // url associated with the object
    var latitude = 0.0  // gps coordinate for latitude
    var longitude = 0.0 // gps coordinate for longitude
    var updatedAt = ""  // last updated date
    
    /* designated initializer */
    init() {
        // just initialize with defaults.
    }
    
    /* designated initializer */
    init(dictionary: [String:AnyObject]) {
        
        if let id = dictionary["objectId"] as? String {
            objectId = id
        }
        
        if let key = dictionary["uniqueKey"] as? String {
            uniqueKey = key
        }
        
        if let first = dictionary["firstName"] as? String {
            firstName = first
        }
        
        if let last = dictionary["lastName"] as? String {
            lastName = last
        }
        
        if let map = dictionary["mapString"] as? String {
            mapString = map
        }
        
        if let url = dictionary["mediaURL"] as? String {
            mediaURL = url
        }
        
        if let lat = dictionary["latitude"] as? Double {
            latitude = lat
        }
        
        if let lon = dictionary["longitude"] as? Double {
            longitude = lon
        }
        
        if let date = dictionary["updatedAt"] as? String {
            updatedAt = date
        }
    }
}

/* example Dictionary:
    {
        "uniqueKey" : "1234",
        "firstName" : "Johnny",
        "lastName" : "Appleseed",
        "mapString" : "San Carlos, CA",
        "mediaURL" : "https://udacity.com",
        "latitude" : 37.4955,
        "longitude" : -122.2668
        "updatedAt" : "2015-09-04T12:58:07.731Z"
    }
*/