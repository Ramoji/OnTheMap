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
    @brief Empty this object's collection of studentLocation objects.
    */
    func reset() {
        studentLocations.removeAll(keepCapacity: false)
    }
    
    /*
    @brief Get an array of student location dictionaries from Parse and update this object's studentLocations collection.
    @discussion This function will recursively call itself, retrieving a limitted number of records on each query, until all records have been acquired from the Parse service.
    @param (in) skip - The number of records to skip when reporting results of the query. To obtain all results use 0.
    */
    func getStudentLocations(skip: Int, completion: (result: Bool, errorString: String?) -> Void) {
        
        var toSkip = skip   // number of records to skip when reporting results of the query
        let limit = 100     // maximum number of records to return from a query
        
        RESTClient.sharedInstance().getStudentLocations(toSkip, limit: limit) { success, arrayOfLocationDictionaries, errorString in
            if errorString == nil {
                if let array = arrayOfLocationDictionaries as? [[String: AnyObject]] {
                    
                    // Update collection of student locations with the new data from Parse.
                    for locationDictionary in array {
                        // create a StudentLocation object and add it to this object's collection.
                        let studentLoc = StudentLocation(dictionary: locationDictionary)
                        self.studentLocations.append(studentLoc)
                    }
                    
                    // Call this function recursively until it the count of retrieved objects < limit. Increment skip by limit each successive query.
                    if let count = arrayOfLocationDictionaries?.count {
                        if count == limit {
                            // There may be more items to retrieve. Query the next batch.
                            toSkip += limit

                            // recursive call
                            self.getStudentLocations(toSkip) { success, errorString in
                                if success == false {
                                    // error retrieving locations. Some but not all locations were retrieved.
                                    println("Error retrieving locations in recursive call to getStudentLocations() in StudentLocations.swift.")
                                    
                                    // Send a notification indicating new student location data has been obtained from Parse.
                                    NSNotificationCenter.defaultCenter().postNotificationName(studentLocationsUpdateNotificationKey, object: self)
                                    
                                    // Fail gracefully by reporting the records that were successfully retrieved prior to the error.
                                    completion(result:true, errorString: nil)
                                } else {
                                    // successfully retrieved locations, and already added to self.studentLocations.
                                }
                            }
                        } else {
                            // All items have been retrieved. Now send notification and call completion handler.
                            
                            // Send a notification indicating new student location data has been obtained from Parse.
                            NSNotificationCenter.defaultCenter().postNotificationName(studentLocationsUpdateNotificationKey, object: self)
                            
                            completion(result:true, errorString: nil)
                        }
                    }
                    
                    println("Total student locations: \(self.studentLocations.count)")
                    
                    // TODO: remove
                    // Send a notification indicating new student location data has been obtained from Parse.
                    //NSNotificationCenter.defaultCenter().postNotificationName(studentLocationsUpdateNotificationKey, object: self)
                } else {
                    // Server responded with success, but a nil array. Do not update local studentLocations.
                    println("new student location data returned a nil array")
                    completion(result:true, errorString: nil)
                }
                // TODO: remove
                //completion(result:true, errorString: nil)
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