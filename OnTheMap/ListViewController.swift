//
//  ListViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up table view delegates
        //TODO
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        appDelegate.getStudentLocations()
    }
    
    /* logout of Udacity session */
    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        RESTClient.sharedInstance().logoutUdacity() {result, error in
            if error == nil {
                println("successfully logged out from Udacity")
                self.displayLoginViewController()
            } else {
                println("Udacity logout failed")
                // TODO: display alertView error
            }
        }
    }
    
    // MARK: Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCellID") as! UITableViewCell
        let studentLocation = appDelegate.studentLocations[indexPath.row] as? [String: AnyObject]
        
        // set the cell text
        var firstName = String(), lastName = String()
        if let location = studentLocation {
            firstName = location["firstName"] as! String
            lastName = location["lastName"] as! String
        }
        cell.textLabel!.text = firstName + " " + lastName
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // open student's url in Safari browser
        let studentLocation: [String: AnyObject] = appDelegate.studentLocations[indexPath.row] as! [String : AnyObject]
        let url = studentLocation["mediaURL"] as! String
        if let requestUrl = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }

}

