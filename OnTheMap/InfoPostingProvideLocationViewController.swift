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

    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func onCancelButtonTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapButtonTap(sender: AnyObject) {
        if let text = locationTextField.text {
            forwardGeoCodeLocation(text)
        }
    }
    
    func forwardGeoCodeLocation(location: String) {
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?[0] as? CLPlacemark {
                
                println("placemark = \(placemark)")
                
                // TODO: re-enable
                //self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
            }
        }
    }
}
