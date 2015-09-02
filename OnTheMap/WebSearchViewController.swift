//
//  WebSearchViewController.swift
//  OnTheMap
//
//  Created by john bateman on 9/1/15.
//  Copyright (c) 2015 John Bateman. All rights reserved.
//
//  This file implements a UIViewController containing a search bar and a UIWebView.
//
// Acknowledgement:  http://stackoverflow.com/questions/26436050/how-do-i-connect-the-search-bar-with-the-uiwebview-in-xcode-6-using-swift

import UIKit
import WebKit

class WebSearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bottomView: UIView!
    
    var initialURL:String? = nil
    var webViewDelegate:UIWebViewDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup search bar delegate to this view controller
        self.searchBar.delegate = self
        
        // adjust background and trancparency of bottom view
        bottomView.backgroundColor = UIColor(white: 1, alpha: 0.85)
        
        // if an initial URL has been set, initialize the search hbar text with it
        if let url = initialURL {
            searchBar.text = url
        }
        
        // if the web view delegate property was set then assign it to the child webView's delegate
        if let delegate = webViewDelegate {
            webView.delegate = delegate
        }
        
        // force the webView to display the searchBar text
        searchBarSearchButtonClicked(searchBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onGoButtonTap(sender: AnyObject) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    @IBAction func onSaveButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        
        // Load web page in UIWebView from search bar text.
        if let text = searchBar.text {
            var url = NSURL(string: text)
            var urlReq = NSURLRequest(URL:url!)
            self.webView!.loadRequest(urlReq)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
