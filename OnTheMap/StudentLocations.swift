//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by john bateman on 7/26/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import Foundation

/* A custom NSNotification that indicates updated student location data has been obtained from Parse. */
let studentLocationsUpdateNotificationKey =  "com.johnbateman.studentLocationsUpdateNotificationKey"

class StudentLocations {
 
    /* An array of StudentLocation objects where each describes the location of a student.*/
    var studentLocations = [StudentLocation]()

    /* This class is instantiated as a Singleton. This function returns the singleton instance. */
   class func sharedInstance() -> StudentLocations {
        
        struct Singleton {
            static var sharedInstance = StudentLocations()
        }
        
        return Singleton.sharedInstance
    }
    
    /*
    @brief Get an array of student location dictionaries from Parse and update this object's studentLocations collection.
    */
    func getStudentLocations(completion: (result: Bool, errorString: String?) -> Void) {
        
        RESTClient.sharedInstance().getStudentLocations() { success, arrayOfLocationDictionaries, errorString in
            if errorString == nil {
                if let array = arrayOfLocationDictionaries as? [[String: AnyObject]] {
                    
                    // Update collection of student locations with the new data from Parse.
                    for locationDictionary in array {
                        // create a StudentLocation object and add it to this object's collection TODO:
                        let studentLoc = StudentLocation(dictionary: locationDictionary)
                        self.studentLocations.append(studentLoc)
                    }
                    
                    // Send a notification indicating new student location data has been obtained from Parse.
                    NSNotificationCenter.defaultCenter().postNotificationName(studentLocationsUpdateNotificationKey, object: self)
                    
                    //TODO remove:
                    // println("new student location data: \(array)")
                } else {
                    // Server responded with success, but a nil array. Do not update local studentLocations.
                    println("new student location data returned a nil array")
                }
                completion(result:true, errorString: nil)
            }
            else {
                println("error getStudentLocations()")
                //self.displayErrorAlertView("Student Location Request Failed", message: errorString!)
                completion(result:false, errorString: errorString)
            }
        }
    }
    
    // MARK: helper functions
    
    func printAllStudentLocations() {
        println("\(studentLocations)")
    }
}