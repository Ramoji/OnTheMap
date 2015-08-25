//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// This file implements the LoginViewController which allows the user to create an account on Udacity, Login to a session on Udacity, or Login to Facebook on the device.

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
    
    /* User selected Login button. Attempt to login to Parse. */
    @IBAction func onLoginButtonTap(sender: AnyObject) {
        startActivityIndicator()
        
        if let username = emailTextField.text, password = passwordTextField.text {
            RESTClient.sharedInstance().loginUdacity(username: username, password: password) {result, accountKey, error in
                if error == nil {
                    self.appDelegate.loggedIn = true
                    
                    // Get the logged in user's data from the Udacity service and store the relevant elements in a studentLocation variable for retrieval later when we post the user's data to Parse.
                    self.getLoggedInUserData(userAccountKey: accountKey) { success, studentLocation, error in
                        if error == nil {
                            // got valid user data back, so save it
                            self.appDelegate.loggedInUser = studentLocation
                        } else {
                            // didn't get valid data back so set to default values
                            self.appDelegate.loggedInUser = StudentLocation()
                        }
                    }
                    
                    // get student locations from Parse
                    self.studentLocations.reset()
                    self.studentLocations.getStudentLocations(0) { success, errorString in
                        if success == false {
                            if let errorString = errorString {
                                OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                            } else {
                                OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                            }
                        } else {
                            // successfully logged in - save the user's account key
                            self.appDelegate.loggedInUser?.uniqueKey = accountKey
                            
                            self.presentMapController()
                        }
                    }
                } else {
                    self.appDelegate.loggedIn = false
                    OTMError(viewController:self).displayErrorAlertView("Login Error", message: error!.localizedDescription)
                }
                
                self.presentMapController()
            }
        }
    }
    
    /* 
    @brief Get user data for logged in user 
    @param (in) userAccountKey: The Udacity account key for the user account.
    */
    func getLoggedInUserData(#userAccountKey: String, completion: (success: Bool, studentLocation: StudentLocation?, error: NSError?) -> Void) {
        
        RESTClient.sharedInstance().getUdacityUser(userID: userAccountKey) { result, studentLocation, error in
            if error == nil {
                completion(success: true, studentLocation: studentLocation, error: nil)
            }
            else {
                println("error getUdacityUser()")
                completion(success: false, studentLocation: nil, error: error)
            }
        }
    }

    /* SignUp button selected. Open Udacity signup page in the Safari web browser. */
    @IBAction func onSignUpButtonTap(sender: AnyObject) {
        let signupUrl = RESTClient.Constants.udacityBaseURL + RESTClient.Constants.udacitySignupMethod
        if let requestUrl = NSURL(string: signupUrl) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            //self.displayMapViewController()
            self.performSegueWithIdentifier("LoginToTabBarSegueID", sender: self)
        }
    }
    
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
    
    /* The Facebook login button was selected. Get the user's Facebook Id and transition to the Map view controller. */
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        appDelegate.loggedIn = true
        
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
    
    /* The user selected the logout facebook button. */
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        appDelegate.loggedIn = false
    }
    
    /* Acquire the user's Facebook user id */
    func getFacebookUserID() {
        //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fbToken = FBSDKAccessToken.currentAccessToken()
        self.appDelegate.loggedInUser?.uniqueKey = fbToken.userID
    }
}
