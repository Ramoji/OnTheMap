//
//  InfoPostingProvideLocationViewController.swift
//  OnTheMap
//
//  Created by john bateman on 7/23/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// This file contains the InfoPosting view controller which allows the user to enter a text description of a location, map it, add a url, and post it to Parse.

import UIKit
import CoreLocation
import MapKit

let LOCATION_VIEW_STATE = 1 // location text field, find on map button
let MAP_VIEW_STATE = 2      // map view, submit button, url text field
let BUSY_VIEW_STATE = 3     // set alpha on subviews to indicate busy state

class InfoPostingProvideLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate {

    var appDelegate: AppDelegate!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var whereAreYouStudyingTodayLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enterLinkToShareTextField: UITextField!
    @IBOutlet weak var browseButton: UIButton!
   
    // constraints
    @IBOutlet weak var constraintMapViewBottomToSuperViewBottom: NSLayoutConstraint!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    var studentLocation: StudentLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // set the mapView delegate to this view controller
        mapView.delegate = self

        // initialize the subviews
        showViewState(LOCATION_VIEW_STATE)

        // initialize text fields
        initTextFields()
        
        // Initialize the tapRecognizer
        initTapRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add the tapRecognizer
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the tapRecognizer
        removeKeyboardDismissRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* User cancelled this view controller. Dismiss it and show parent. */
    @IBAction func onCancelButtonTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /* User selected Browse button. Display an embedded webkit browser view with search. Show the user's selected url. If no url is selected display the default www.google.com url. */
    @IBAction func onBrowseButtonTap(sender: AnyObject) {
        var url = "http://www.google.com"
        if let userLink = enterLinkToShareTextField.text {
            if userLink != "" {
                url = userLink
            }
        }
        showEmbeddedBrowserWithSearch(url)
    }
    
    /* Attempt to forward geocode the address entered by the user. If that works drop a pin on the map. */
    @IBAction func findOnMapButtonTap(sender: AnyObject) {
        if let text = locationTextField.text {
            // show UIActivityViewIndicator
            startActivityIndicator()
            
            showViewState(BUSY_VIEW_STATE)
            
            forwardGeoCodeLocation(text) { placemark, error in
                self.stopActivityIndicator()
                
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a student location object
                        self.studentLocation = self.createStudentLocation(placemark)
                        
                        // update UI state to reveal map and submit button
                        self.showViewState(MAP_VIEW_STATE)
                        
                        if let studentLocation = self.studentLocation {
                            self.showPinOnMap(studentLocation)
                        }
                        
                    } else {
                        // alertview for error - geocode to clplacemark failed and returned a nil placemark
                        OTMError(viewController:self).displayErrorAlertView("Geocoding error", message: "Failed to forward geocode \(text)")
                    }
                } else {
                    // alertview for error - geocode to clplacemark failed
                    OTMError(viewController:self).displayErrorAlertView("Geocoding error", message: "Failed to forward geocode \(text)")
                }
            }
        }
    }
    
    /* Create a StudentLocation object. */
    func createStudentLocation(placemark: CLPlacemark) -> StudentLocation {
        
        // Get the Udacity key for the logged in user that was saved upon successful login.
        var uniqueKey = ""
        if let loggedInUser = appDelegate.loggedInUser {
            uniqueKey = loggedInUser.uniqueKey
        }
        
        // Create a placeDictionary with the user's Udacity login credentials and the url the user just entered on this screen.
        var placeDictionary: [String: AnyObject] = [
            "uniqueKey" : uniqueKey,
            "firstName" : self.appDelegate.loggedInUser!.firstName,
            "lastName" : self.appDelegate.loggedInUser!.lastName,
            "mediaURL" : enterLinkToShareTextField.text,
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
    
    /* 
    @brief Forward geocode the location string entered by the user.
    @return Returns a Placemark object in the completion handler representing the forward geocoded location.
    */
    func forwardGeoCodeLocation(location: String, completion: (placemark: CLPlacemark?, error: NSError?) -> Void) -> Void {
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as? CLPlacemark {
                completion(placemark: placemark, error: nil)
            } else {
                completion(placemark: nil, error: error)
            }
        }
    }
    
    /* Submit button was selected by the user. Try to post the student location to Parse.*/
    @IBAction func onSubmitButtonTap(sender: AnyObject) {
        
        if let text = enterLinkToShareTextField.text {
            if text == "" {
                // url string is empty
                OTMError(viewController:self).displayErrorAlertView("Forgot Link", message: "Please provide a link to a website and reselect submit.")
            } else {
                // URL string is not empty
                if var loc = studentLocation {
                    
                    // Save the link entered by the user in the StudentLocation data structure.
                    loc.mediaURL = text
                    self.studentLocation?.mediaURL = text
                    
                    // Post the student location to Parse
                    RESTClient.sharedInstance().postStudentLocationToParse(loc) {result, error in
                        if error == nil {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            // display error message to user
                            var errorMessage = "error"
                            if let errorString = error?.localizedDescription {
                                errorMessage = errorString
                            }
                            OTMError(viewController:self).displayErrorAlertView("Submit Failed", message: errorMessage)
                        }
                    }
                }
            }
            
        } else {
            // url string is nil
            OTMError(viewController:self).displayErrorAlertView("Forgot Link", message: "Please provide a link to a website and reselect submit.")
        }
    }
    
    /* 
    @brief Show and hide views based on state.
    @param (in) state - Should be one of the following: LOCATION_VIEW_STATE, MAP_VIEW_STATE, or BUSY_VIEW_STATE. (These states are described at the top of this file.)
    */
    func showViewState(state: Int) {
        switch state {
            
        case LOCATION_VIEW_STATE:
            // enter location. Find on the Map button.
            locationTextField.hidden = false
            mapView.hidden = true
            submitButton.hidden = true
            findOnMapButton.hidden = false
            whereAreYouStudyingTodayLabel.hidden = false
            enterLinkToShareTextField.hidden = true
            browseButton.hidden = true
            
        case MAP_VIEW_STATE:
            // map. Submit button.
            locationTextField.hidden = true
            mapView.hidden = false
            submitButton.hidden = false
            findOnMapButton.hidden = true
            whereAreYouStudyingTodayLabel.hidden = true
            enterLinkToShareTextField.hidden = false
            browseButton.hidden = false
            
            topView.backgroundColor = UIColor(red: 91/255, green: 134/255, blue: 237/255, alpha: 1)
            bottomView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            self.view.layoutIfNeeded()
        
        case BUSY_VIEW_STATE:
            locationTextField.alpha = 0.3
            findOnMapButton.alpha = 0.3
            whereAreYouStudyingTodayLabel.alpha = 0.3
            
        default:
            locationTextField.hidden = false
            mapView.hidden = true
            submitButton.hidden = true
            findOnMapButton.hidden = false
            whereAreYouStudyingTodayLabel.hidden = false
            enterLinkToShareTextField.hidden = true
            browseButton.hidden = true
            
            topView.backgroundColor = UIColor.clearColor()
        }
        mapView.setNeedsDisplay()
    }
    
    
    // MARK: - MKMapViewDelegate
    
    /*
    @brief Create an accessory view for the pin annotation callout when it is added to the map view.
    @discussion Make the pin color purple to identify it as a pin the user placed on the map.
    */
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Purple
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    /*
    @brief This delegate method is implemented to respond to taps. 
    @discussion It opens the system browser to the URL specified in the annotationViews subtitle property.
    */
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let link = annotationView.annotation.subtitle {
                if let url = NSURL(string: link) {
                    app.openURL(url)
                }
            }
        }
    }
    
    
    // MARK: helper functions
    
    /* Configure initial text attributes on text fields */
    func initTextFields() {
        
        locationTextField.delegate = self
        enterLinkToShareTextField.delegate = self
        
        // set attributes of placeholder text on text fields
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Location Here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        enterLinkToShareTextField.attributedPlaceholder = NSAttributedString(string: "Enter a Link to Share Here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // hide border on text fields
        locationTextField.borderStyle = UITextBorderStyle.None
        enterLinkToShareTextField.borderStyle = UITextBorderStyle.None
    }

    /* Displays the current studentLocation on the mapView. */
    func showPinOnMap(location: StudentLocation) {
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude )
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        var annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(location.firstName) \(location.lastName)"
        annotation.subtitle = location.mediaURL
        
        
        // Add the annotation to an array of annotations.
        var annotations = [MKPointAnnotation]()
        annotations.append(annotation)
        
        // Add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        // Set the center of the map.
        self.mapView.setCenterCoordinate(coordinate, animated: true)
        
        // Tell the OS that the mapView needs to be refreshed.
        self.mapView.setNeedsDisplay()
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
    
    
    // MARK: Text View Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // hide keyboard when Return is selected while editing a text field
        locationTextField.resignFirstResponder()
        enterLinkToShareTextField.resignFirstResponder()
        return true;
    }
    
    
    // MARK: Tap gesture recognizer
    
    func initTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    // Add the recognizer to dismiss the keyboard
    func addKeyboardDismissRecognizer() {
        
        if let tapRecog = tapRecognizer {
            // tapRecog.delegate = self
            self.view.addGestureRecognizer(tapRecog)
        }
        self.view.userInteractionEnabled = true
    }
    
    // remove the tap gesture recognizer
    func removeKeyboardDismissRecognizer() {
        
        if let tapRecog = tapRecognizer {
            view.removeGestureRecognizer(tapRecog)
        }
    }
    
    // User tapped somewhere on the view. End editing.
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /* Display url in an embeded webkit browser with a search bar in the navigation controller. */
    func showEmbeddedBrowserWithSearch(url: String) {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("WebSearchStoryboardID") as! WebSearchViewController
        controller.initialURL = url
        controller.webViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
//    /* Create a UIWebView the size of the screen and set it's delegate to this view controller. */
//    func showWebView(url: String?) {
//        let webView:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        webView.delegate = self
//        if let url = url {
//            webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
//            self.view.addSubview(webView)
//        }
//    }
//    
//    
    // MARK: UIWebViewDelegate methods
    
    /* Called every time the URL changes in the UIWebView. This function keeps the LinkToShare text field in the UI updated with each change to the web page. */
    func webViewDidFinishLoad(webView: UIWebView) {
        if let currentURL = webView.request?.URL?.absoluteString {
            println("The current url is \(currentURL)")
            enterLinkToShareTextField.text = currentURL
        }
    }
}
