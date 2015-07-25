//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

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
    func getStudentLocations() {
        RESTClient.sharedInstance().getStudentLocations() { success, arrayOfLocationDictionaries, errorString in
            if errorString == nil {
                if let array = arrayOfLocationDictionaries {
                    
                    // Update collection of student locations with the new data from Parse.
                    self.studentLocations = array
                    
                    // Send a notification indicating new student location data has been obtained from Parse.
                    NSNotificationCenter.defaultCenter().postNotificationName(self.studentLocationsUpdateNotificationKey, object: self)
                }
            }
            else {
                println("error getStudentLocations()")
            }
        }
    }

}

