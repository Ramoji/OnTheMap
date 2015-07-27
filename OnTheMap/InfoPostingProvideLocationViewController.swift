//
//  InfoPostingProvideLocationViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class InfoPostingProvideLocationViewController: UIViewController {

    var appDelegate: AppDelegate!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var whereAreYouStudyingTodayLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
   
    var studentLocation: StudentLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // show initial set of controls
        presentFindOnMapViewState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // show initial set of controls
        presentFindOnMapViewState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButtonTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* Attempt to forward geocode the address entered by the user. If that works drop a pin on the map. */
    @IBAction func findOnMapButtonTap(sender: AnyObject) {
        if let text = locationTextField.text { // TODO: switch references to testText back to text
            let testText = "obloabli23kdf"//"San Mateo, CA" // TODO: -remove once able to interact with locationTextField
            
            // TODO: show UIActivityViewIndicator (storyboard, show,hide approach)
            
            forwardGeoCodeLocation(testText) { placemark, error in
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a student location object
                        self.studentLocation = self.createStudentLocation(placemark)
                        
                        // update UI state to reveal map and submit button
                        self.presentSubmitViewState()
                        
                    } else {
                        //TODO: alertview for error - geocode to clplacemark failed and returned a nil placemark
                        OTMError(viewController:self).displayErrorAlertView("Geocoding error", message: "Failed to forward geocode \(testText)")
                    }
                } else {
                    //TODO: alertview for error - geocode to clplacemark failed
                    OTMError(viewController:self).displayErrorAlertView("Geocoding error", message: "Failed to forward geocode \(testText)")
                }
            }
        }
    }
    
    /* Create a StudentLocation object. */
    func createStudentLocation(placemark: CLPlacemark) -> StudentLocation {
        var placeDictionary: [String: AnyObject] = [
            "uniqueKey" : appDelegate.userAccountKey,
            "firstName" : "Racer",
            "lastName" : "X",
            "mediaURL" : "https://udacity.com",
            "latitude" : placemark.location.coordinate.latitude,
            "longitude" : placemark.location.coordinate.longitude
        ]
        var mapString = ""
        if let city = placemark.addressDictionary["City"] as? String {
            mapString += city
        }
        if let state = placemark.addressDictionary["State"] as? String {
            mapString += ", "
            mapString += state
        }
        if let country = placemark.addressDictionary["Country"] as? String {
            mapString += ", "
            mapString += country
        }
        if mapString != "" {
            placeDictionary["mapString"] = mapString
        }
        return StudentLocation(dictionary: placeDictionary)
    }
    
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as? CLPlacemark {
                println("placemark = \(placemark)")
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
    
    @IBAction func onSubmitButtonTap(sender: AnyObject) {
        if let loc = studentLocation {
            RESTClient.sharedInstance().postStudentLocationToParse(loc) {result, error in
                if error == nil {
                    println("successfully posted StudentLocation to Parse")
                } else {
                    println("error posting StudentLocation to Parse")
                }
            }
        }
    }
    
    /* Shows/hides views to allow user to enter an address and select the [Find on Map] button. */
    func presentFindOnMapViewState() {
//        topView.hidden = false
//        middleView.hidden = true
//        bottomView.hidden = false
        
//        topView.hidden = false
//        middleView.hidden = true
//        bottomView.hidden = false
//        whereAreYouStudyingTodayLabel.hidden = false
//        locationTextField.hidden = false
//        findOnMapButton.hidden = false
//        submitButton.hidden = true
//        cancelButton.hidden = false
//        mapView.hidden = true
//        self.view.setNeedsDisplay()
    }
    
    /* Shows/hides views to display map view and Submit button. */
    func presentSubmitViewState() {
//        topView.hidden = false
//        middleView.hidden = true
//        bottomView.hidden = true
//        whereAreYouStudyingTodayLabel.hidden = true
//        locationTextField.hidden = true
//        findOnMapButton.hidden = true
//        submitButton.hidden = false
//        cancelButton.hidden = false
//        mapView.hidden = false
//        self.view.setNeedsDisplay()
    }
}
