//
//  MapViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  Used code from Udacity PinSample to display annotations on the MapView

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // request student locations from Parse
        appDelegate.getStudentLocations()
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Add a notification observer for updates to student location data from Parse.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onStudentLocationsUpdate", name: appDelegate.studentLocationsUpdateNotificationKey, object: nil)
        
        // Redraw the pins
        //self.mapView.setNeedsDisplay()

        createPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If not logged in present the LoginViewController.
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if delegate.loggedIn == false {
            displayLoginViewController()
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

    func displayLoginViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }

    func displayInfoPostingViewController() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InfoPostingProvideLocationStoryboardID") as! InfoPostingProvideLocationViewController
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    func onPinButtonTap() {
        displayInfoPostingViewController()
        
        // TODO - remove: createPins()
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
    func onStudentLocationsUpdate() {
        createPins()
        println("onStudentLocationsUpdate()")
    }
    
    /* Create an annotation for each studentLocation and display them on the map */
    func createPins() {
        
        // A collection of point annotations to be displayed on the map view
        var annotations = [MKPointAnnotation]()
        
        // Create an annotation for each location dictionary in studentLocations
        for dictionary in appDelegate.studentLocations {
            
            // get latitude and longitude from studentLocation dictionary and save as CCLocationDegree type (a Double type)
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // extract the student name and url from the dictionary
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let url = dictionary["mediaURL"] as! String
            
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
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
}

