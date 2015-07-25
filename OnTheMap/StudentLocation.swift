//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by john bateman on 7/25/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import Foundation

class StudentLocation {
    
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    
    /* designated initializer */
    init(dictionary: [String:AnyObject]) {
        
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
    }
}

/* example:
    {
        "uniqueKey" : "1234",
        "firstName" : "Johnny",
        "lastName" : "Appleseed",
        "mapString" : "San Carlos, CA",
        "mediaURL" : "https://udacity.com",
        "latitude" : 37.4955,
        "longitude" : -122.2668
    }
*/