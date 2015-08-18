//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    var appDelegate: AppDelegate!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Setup facebook login...
        // Facebook Login
        loginButton.delegate = self
        // request access to user's facebook profile, email, and friends
        self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // The user is already logged in to Facebook on this device.
            appDelegate.loggedIn == true
            
            // Acquire the user's facebook user id.
            getFacebookUserID()
        }
        
        // If already logged in to Udacity or Facebook present the Tab Bar conttoller.
        if appDelegate.loggedIn == true {
            presentMapController()
        }
        
        // inset text in edit text fields
        var insetView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        emailTextField.leftViewMode = UITextFieldViewMode.Always
        emailTextField.leftView = insetView
        
        var insetViewPwd = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        passwordTextField.leftView = insetViewPwd
        
        // set placeholder text color to white in edit text fields
        emailTextField.attributedPlaceholder = NSAttributedString(string:"Email",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
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
        startActivityIndicator()
        
        //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // TODO: remove. These 2 lines are for debug convenience to avoid having to login.
//        delegate.loggedIn = true
//        self.dismissViewControllerAnimated(true, completion: nil)
//        return
        
        if let username = emailTextField.text, password = passwordTextField.text {
            RESTClient.sharedInstance().loginUdacity(username: username, password: password) {result, accountKey, error in
                if error == nil {
                    self.appDelegate.loggedIn = true
                    
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
                            self.appDelegate.userAccountKey = accountKey
                            //self.dismissViewControllerAnimated(true, completion: nil)
                            
                            self.presentMapController()
//                            dispatch_async(dispatch_get_main_queue()) {
//                                self.displayMapViewController()
//                            }
                        }
                    }
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.appDelegate.loggedIn = false
                    OTMError(viewController:self).displayErrorAlertView("Login Error", message: error!.localizedDescription)
                }
                
                self.presentMapController()
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.stopActivityIndicator()
//                }
            }
        }
    }

    @IBAction func onSignUpButtonTap(sender: AnyObject) {
        if let requestUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    @IBAction func onLoginWithFacebookButtonTap(sender: AnyObject) {
        // TODO: make login call to Facebook API
    }
    
//    func displayTabBarController() {
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("TabBarControllerStoryboardID") as! UITabBarController
//        self.presentViewController(controller, animated: true, completion: nil);
//    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            //self.displayMapViewController()
            self.performSegueWithIdentifier("LoginToTabBarSegueID", sender: self)
        }
    }

//    /* present the MapView controller */
//    func displayMapViewController() {
//        performSegueWithIdentifier("LoginToTabBarSegueID", sender: self)
//    }
    
    /* show activity indicator */
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /* hide acitivity indicator */
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        appDelegate.loggedIn = true
        
        println("User logged in to Facebook")
        
        if ((error) != nil)
        {
            // Process the error
        }
        else if result.isCancelled {
            // Handle the cancellation
        }
        else {
            // Acquire the user's facebook user id
            getFacebookUserID()
            
            // Verify permissions were granted.
            if result.grantedPermissions.contains("email")
            {
                println("facebook email permission granted")
            }
            
            if result.grantedPermissions.contains("public_profile")
            {
                println("facebook public_profile permission granted")
            }
            
            if result.grantedPermissions.contains("user_friends")
            {
                println("facebook user_friends permission granted")
            }
            
            // present the MapViewController
            presentMapController()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        appDelegate.loggedIn = false
        println("User logged out of Facebook")
    }
    
    /* Acquire the user's Facebook user id */
    func getFacebookUserID() {
        //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fbToken = FBSDKAccessToken.currentAccessToken()
        appDelegate.userAccountKey = fbToken.userID
    }
}
