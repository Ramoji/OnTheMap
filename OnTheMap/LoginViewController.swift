//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // If already logged in present the Tab Bar conttoller.
        if appDelegate.loggedIn == true {
            displayMapViewController()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButtonTap(sender: AnyObject) {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // TODO: remove. These 2 lines are for debug convenience to avoid having to login.
//        delegate.loggedIn = true
//        self.dismissViewControllerAnimated(true, completion: nil)
//        return
        
        if let username = emailTextField.text, password = passwordTextField.text {
            RESTClient.sharedInstance().loginUdacity(username: username, password: password) {result, accountKey, error in
                if error == nil {
                    delegate.loggedIn = true
                    
                    // get student locations from Parse
                    /*TODO: Remove: self.appDelegate.*/ self.studentLocations.getStudentLocations() { success, errorString in
                        if success == false {
                            if let errorString = errorString {
                                OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                                //self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                                //self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        } else {
                            // successfully logged in - save the user's account key
                            delegate.userAccountKey = accountKey
                            //self.dismissViewControllerAnimated(true, completion: nil)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.displayMapViewController()
                            }
                        }
                    }
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    delegate.loggedIn = false
                    OTMError(viewController:self).displayErrorAlertView("Login Error", message: error!.localizedDescription)
                }
            }
        }
    }

    @IBAction func onLoginWithFacebookButtonTap(sender: AnyObject) {
        // TODO: make login call to Facebook API
    }
    
    func displayTabBarController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("TabBarControllerStoryboardID") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func displayMapViewController() {
        performSegueWithIdentifier("LoginToTabBarSegueID", sender: self)
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("MapViewControllerStoryboardID") as! UINavigationController
//        self.presentViewController(controller, animated: true, completion: nil);
    }
}
