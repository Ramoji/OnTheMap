//
//  ListViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    var delegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        delegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        delegate.getStudentLocations()
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
}

