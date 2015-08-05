//
//  ListViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: register observer for studentLocation updates
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to student location data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onStudentLocationsUpdate", name: studentLocationsUpdateNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the studentLocations update notification.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayLoginViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func onPinButtonTap() {
        
    }
    
    func onRefreshButtonTap() {
        // refresh the collection of student locations from Parse
        /*TODO - remove: appDelegate.*/studentLocations.getStudentLocations() { success, errorString in
            if success == false {
                if let errorString = errorString {
                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                } else {
                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                }
            }
        }
    }
    
    /* logout of Udacity session */
    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        RESTClient.sharedInstance().logoutUdacity() {result, error in
            if error == nil {
                println("successfully logged out from Udacity")
                self.appDelegate.loggedIn = false
                self.displayLoginViewController()
            } else {
                println("Udacity logout failed")
                // TODO: display alertView error
            }
        }
    }
    
    /* Received a notification that studentLocations have been updated with new data from Parse. Recreate the pins for all locations. */
    func onStudentLocationsUpdate() {
        self.tableView.reloadData()
        println("onStudentLocationsUpdate()")
    }
    
    // MARK: Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO - remove: return appDelegate.studentLocations.count
        return studentLocations.studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCellID") as! UITableViewCell
// TODO: remove
//        let studentLocation = appDelegate.studentLocations[indexPath.row] as? [String: AnyObject]
//
//        // set the cell text
//        var firstName = String(), lastName = String()
//        if let location = studentLocation {
//            firstName = location["firstName"] as! String
//            lastName = location["lastName"] as! String
//        }
        
        let studentLocation = studentLocations.studentLocations[indexPath.row]
        
        // set the cell text
        var firstName = studentLocation.firstName
        var lastName = studentLocation.lastName
        cell.textLabel!.text = firstName + " " + lastName
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // open student's url in Safari browser
//        let studentLocation: [String: AnyObject] = appDelegate.studentLocations[indexPath.row] as! [String : AnyObject]
//        let url = studentLocation["mediaURL"] as! String
        
        let studentLocation = studentLocations.studentLocations[indexPath.row]
        let url = studentLocation.mediaURL
        
        if let requestUrl = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }

}

