//
//  MapViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  Acknowledgement: Used code from Udacity PinSample to display annotations on the MapView
//
//  This file contains the MapViewController, the first view controller in the Tab View Controller.


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
    let studentLocations = StudentLocations.sharedInstance()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Add a notification observer for updates to student location data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onStudentLocationsUpdate", name: studentLocationsUpdateNotificationKey, object: nil)
        
        // Clear any existing pins before redrawing them (e.g. if navigating back to the map view from the InfoPosting view.)
        removeAllPins()
        
        // Draw the pins now (as it is conceivable that the notification arrived prior to the observer being registered.)
        createPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If not logged in present the LoginViewController.
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if delegate.loggedIn == false {
            displayLoginViewController()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
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

    /* Modally present the Login view controller. */
    func displayLoginViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }

    /* Modally present the InfoPosting view controller. */
    func displayInfoPostingViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InfoPostingProvideLocationStoryboardID") as! InfoPostingProvideLocationViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* Pin button was selected. */
    func onPinButtonTap() {
        displayInfoPostingViewController()
    }
    
    /* Refresh button was selected. */
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
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    /* logout of Facebook else logout of Udacity session */
    @IBAction func onLogoutButtonTap(sender: AnyObject) {
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
            self.displayLoginViewController()
        } else {
            // Udacity logout
            RESTClient.sharedInstance().logoutUdacity() {result, error in
                if error == nil {
                    self.appDelegate.loggedIn = false
                    self.displayLoginViewController()
                } else {
                    println("Udacity logout failed")
                    // no display to user
                }
            }
        }
    }
    
    /* Received a notification that studentLocations have been updated with new data from Parse. Recreate the pins for all locations. */
    func onStudentLocationsUpdate() {
        // clear the pins
        removeAllPins()
        
        // redraw the pins
        createPins()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    /* Create an annotation for each studentLocation and display them on the map */
    func createPins() {
        
        // A collection of point annotations to be displayed on the map view
        var annotations = [MKPointAnnotation]()
        
        // Create an annotation for each location dictionary in studentLocations
        for location in studentLocations.studentLocations {
            
            // get latitude and longitude from studentLocation and save as CCLocationDegree type (a Double type)
            let lat = CLLocationDegrees(location.latitude as Double)
            let long = CLLocationDegrees(location.longitude as Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // extract the student name and url from the dictionary
            let first = location.firstName
            let last = location.lastName
            let url = location.mediaURL
            
            // Create the annotation, setting the coordinate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = url
            
            // Add annotation to the annotations collection.
            annotations.append(annotation)
        }
        
        // Add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        self.mapView.setNeedsDisplay()
    }
    
    /* 
    @brief - Remove all annotations from the MKMapView.
    Acknowledgement:  nielsbot, SO for filter technique to remove all but users current location.
    */
    func removeAllPins() {
        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
        self.mapView.removeAnnotations( annotationsToRemove )
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Create an accessory view for the pin annotation callout when it is added to the map view
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            if let urlString = annotationView.annotation.subtitle {
                if let requestUrl = NSURL(string: urlString) {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
            }
        }
        
    }
}

