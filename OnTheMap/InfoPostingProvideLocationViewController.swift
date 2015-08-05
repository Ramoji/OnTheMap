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

class InfoPostingProvideLocationViewController: UIViewController, MKMapViewDelegate {

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
    @IBOutlet weak var enterLinkToShareTextField: UITextField!
   
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
        showViewState(1)

        // initialize text fields
        initTextFields()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        if let text = locationTextField.text {
            // show UIActivityViewIndicator (storyboard, show,hide approach)
            startActivityIndicator()
            
            forwardGeoCodeLocation(text) { placemark, error in
                self.stopActivityIndicator()
                
                if error == nil {
                    if let placemark = placemark {
                        // place pin on map
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        // initialize a student location object
                        self.studentLocation = self.createStudentLocation(placemark)
                        
                        // update UI state to reveal map and submit button
                        self.showViewState(2)
                        
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
        
        if let text = enterLinkToShareTextField.text {
            if text == "" {
                // url string is empty
                OTMError(viewController:self).displayErrorAlertView("Forgot Link", message: "Please provide a link to a website and reselect submit.")
            } else {
                // URL string is not empty
                if let loc = studentLocation {
                    RESTClient.sharedInstance().postStudentLocationToParse(loc) {result, error in
                        if error == nil {
                            println("successfully posted StudentLocation to Parse")
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            // display error message to user
                            println("error posting StudentLocation to Parse")
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
            OTMError(viewController:self).displayErrorAlertView("Forgot Link", message: "Pleaes provide a link to a website and reselect submit.")
        }
    }
    
    /* show and hide views based on state */
    func showViewState(state: Int) {
        switch state {
            
        case 1:
            // enter location. Find on the Map button.
            locationTextField.hidden = false
            mapView.hidden = true
            submitButton.hidden = true
            findOnMapButton.hidden = false
            whereAreYouStudyingTodayLabel.hidden = false
            enterLinkToShareTextField.hidden = true
            
        case 2:
            // map. Submit button.
            locationTextField.hidden = true
            mapView.hidden = false
            submitButton.hidden = false
            findOnMapButton.hidden = true
            whereAreYouStudyingTodayLabel.hidden = true
            enterLinkToShareTextField.hidden = false
            
            topView.backgroundColor = UIColor(red: 91/255, green: 134/255, blue: 237/255, alpha: 1)
            bottomView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            self.view.layoutIfNeeded()
            
        default:
            locationTextField.hidden = false
            mapView.hidden = true
            submitButton.hidden = true
            findOnMapButton.hidden = false
            whereAreYouStudyingTodayLabel.hidden = false
            enterLinkToShareTextField.hidden = true
            
            topView.backgroundColor = UIColor.clearColor()
        }
        mapView.setNeedsDisplay()
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Create an accessory view for the pin annotation callout when it is added to the map view.
    // Make the pin color purple to identify it as a pin the user placed on the map.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    // MARK: helper functions
    
    /* Configure initial text attributes on text fields */
    func initTextFields() {
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
    
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
