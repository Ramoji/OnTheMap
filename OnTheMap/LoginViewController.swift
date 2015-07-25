//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onLoginButtonTap(sender: AnyObject) {
        // TODO: make real login call to Udacity API
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // debug
        // delegate.loggedIn = true
        // self.dismissViewControllerAnimated(true, completion: nil)
        
        if let username = emailTextField.text, password = passwordTextField.text {
            RESTClient.sharedInstance().loginUdacity(username: username, password: password) {result, error in
                if error == nil {
                    delegate.loggedIn = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    // TODO - move this to the map and list VCs. Here it is for debug only.
//                    RESTClient.sharedInstance().logoutUdacity() {result, error in
//                        if error == nil {
//                            println("logged out")
//                        } else {
//                            println("logout failed")
//                        }
//                    }
                    
                } else {
                    delegate.loggedIn = false
                    // TODO - display alertview
                }
            }
        }
    }

    @IBAction func onLoginWithFacebookButtonTap(sender: AnyObject) {
        // TODO: make real login call to Facebook API
    }
    
}
