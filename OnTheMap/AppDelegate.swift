//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /* true if the user has loggedIn to Udacity, else false */
    var loggedIn = false
    
    /* An array of dictionaries where each dictionary describes the location of a student.*/
    var studentLocations = [AnyObject]()
    
    /* A custom NSNotification that indicates updated student location data has been obtained from Parse. */
    let studentLocationsUpdateNotificationKey =  "com.johnbateman.studentLocationsUpdateNotificationKey"

    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /* 
        @brief Get an array of student location dictionaries from Parse.
    */
    func getStudentLocations(completion: (result: Bool, errorString: String?) -> Void) {
        RESTClient.sharedInstance().getStudentLocations() { success, arrayOfLocationDictionaries, errorString in
            if errorString == nil {
                if let array = arrayOfLocationDictionaries {
                    // Update collection of student locations with the new data from Parse.
                    self.studentLocations = array
                    
                    // Send a notification indicating new student location data has been obtained from Parse.
                    NSNotificationCenter.defaultCenter().postNotificationName(self.studentLocationsUpdateNotificationKey, object: self)
                    
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
    
    // MARK: test functions - TODO: remove

    func test() {
        let testText = "San Mateo, CA"
        forwardGeoCodeLocation(testText) { placemark, error in
            if error == nil {
                if let placemark = placemark {
                    
                    
                    
                    println("placemark:")
                    //println("placemark \(placemark)")
                    println("latitude : \(placemark.location.coordinate.latitude), longitude : \(placemark.location.coordinate.longitude)")
                    //println( "locality: \(placemark.addressDictionary[placemark.locality])")
                    //println( "administrative area: \(placemark.addressDictionary[placemark.administrativeArea])")
                    
                    if let locality = placemark.addressDictionary["locality"] as? String {
                        println("city: \(locality)")
                    }
                    if let subAdminArea = placemark.addressDictionary["SubAdministrativeArea"] as? String {
                        println( "subadministrative area: \(subAdminArea)")
                    }
                    if let state = placemark.addressDictionary["State"] as? String {
                        println( "State: \(state)")
                    }
                    if let country = placemark.addressDictionary["Country"] as? String {
                        println( "Country: \(country)")
                    }
                    if let addressLines = placemark.addressDictionary["FormattedAddressLines"] as? String {
                        println( "FormattedAddressLines: \(addressLines)")
                    }
                    if let structuredAddress = placemark.addressDictionary["structuredAddress"] as? String {
                        println( "structuredAddress: \(structuredAddress)")
                    }
                    if let name = placemark.addressDictionary["Name"] as? String {
                        println( "Name: \(name)")
                    }
                    if let city = placemark.addressDictionary["City"] as? String {
                        println( "City: \(city)")
                    }
                    
                    println( "addressDictionary: \(placemark.addressDictionary)")
                    
                } else {
                    //TODO: alertview for error - geocode to clplacemark failed and returned a nil placemark
                }
            } else {
                //TODO: alertview for error - geocode to clplacemark failed
            }
        }
    }
    
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as? CLPlacemark {
                println("placemark = \(placemark)")
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
}

