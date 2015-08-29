//
//  WebViewController.swift
//  OnTheMap
//
//  Created by john bateman on 8/25/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
// This file implements teh WebViewController class which displays a url in a WKWebView.


import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView?
    var url: String?
    
    override func loadView() {
        super.loadView()
        
        // create a WKWebView
        self.webView = WKWebView()
        
        // assign the WKWebView to the view controller's view
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 
    @brief Load the web page identified by the url parameter in the WKWebView
    @param (in) url - The web page to display.
    */
    func loadUrl(url: String?) {
        if let url = url {
            var nsurl = NSURL(string:url)
            if let nsurl = nsurl {
                var request = NSURLRequest(URL:nsurl)
                self.webView!.loadRequest(request)
            }
        }
    }
}
