//
//  CollectionViewController.swift
//  OnTheMap
//
//  Created by john bateman on 8/28/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// This file implements the LoginViewController which allows the user to create an account on Udacity, Login to a session on Udacity, or Login to Facebook on the device.

import UIKit

let reuseIdentifier = "OTMCollectionCellID"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegate {

    @IBOutlet weak var theCollectionView: UICollectionView!
    
    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // setup the collectionview datasource & delegate
        theCollectionView.dataSource = self
        theCollectionView.delegate = self
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    /* return the section count */
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    /* return the item count */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studentLocations.studentLocations.count
    }

    /* return a cell for the requested item */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionCell
    
        let studentLocation = studentLocations.studentLocations[indexPath.row]
        
        // set the cell text
        var firstName = studentLocation.firstName
        var lastName = studentLocation.lastName
        cell.label!.text = firstName + " " + lastName
        
        println("cell label = \(cell.label!.text)")
        
        return cell
    }

    
    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // open student's url in Safari browser
        let studentLocation = studentLocations.studentLocations[indexPath.row]
        let url = studentLocation.mediaURL
        
        showUrlInEmbeddedBrowser(url)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    // MARK: button handlers
    
    /* The Pin button was selected. */
    func onPinButtonTap() {
        displayInfoPostingViewController()
    }
    
    /* The Refresh button was selected. */
    func onRefreshButtonTap() {
        // refresh the collection of student locations from Parse
        studentLocations.reset()
        studentLocations.getStudentLocations(0) { success, errorString in
            if success == false {
                if let errorString = errorString {
                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
                } else {
                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
                }
            }
        }
    }
    
    /* logout of Facebook else logout of Udacity session */
    @IBAction func onLogoutButtonTap(sender: AnyObject) {
        startActivityIndicator()
        
        // Facebook logout
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is logged in with Facebook. Log user out of Facebook.
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            if (FBSDKAccessToken.currentAccessToken() == nil)
            {
                self.appDelegate.loggedIn = false
            }
            self.stopActivityIndicator()
            self.displayLoginViewController()
        } else {
            // Udacity logout
            RESTClient.sharedInstance().logoutUdacity() {result, error in
                self.stopActivityIndicator()
                if error == nil {
                    // successfully logged out
                    self.appDelegate.loggedIn = false
                    self.displayLoginViewController()
                } else {
                    println("Udacity logout failed")
                    // no display to user
                }
            }
        }
    }
    
    // MARK: helper functions
    
    /* Modally present the Login view controller */
    func displayLoginViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Modally present the InfoPosting view controller */
    func displayInfoPostingViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InfoPostingProvideLocationStoryboardID") as! InfoPostingProvideLocationViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Received a notification that studentLocations have been updated with new data from Parse. Update the items in the collection view. */
    func onStudentLocationsUpdate() {
        // Provoke the collection view data source protocol methods to be called.
        self.theCollectionView.reloadData()
    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let requestUrl = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    /* Display url in an embeded webkit browser in the navigation controller. */
    func showUrlInEmbeddedBrowser(url: String) {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("WebViewStoryboardID") as! WebViewController
        controller.url = url
        self.navigationController?.pushViewController(controller, animated: true)
        
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

}
