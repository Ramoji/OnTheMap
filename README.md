# OnTheMap
This iOS 8 Swift app uses Udacity login REST api and Parse REST api to acquire a list of student location metadata and display it on a map.

## Implementation Highlights

* MVC design pattern with strict separation between model and view.
* Data persisted to Parse via REST API.
* Login via Udacity REST API or Facebook SDK, and logout.
* Asynchronous requests to Parse REST API in background queue in network friendly manner using recursion.
* Separation of REST API calls in model classes to maintain MVC and keep view controllers lightweight.
* Common NSURLSession networking code refactored into a separate class to keep the code DRY.
* JSON Parsing of http responses.
* Table view embedded in a view controller using UITableView, UITableViewDelegate and UITableViewDataSource protocols.
* Collection view implemented with UICollectionViewController, UICollectionViewDelegate protocol.
* MapKit
* Singleton pattern and NSNotification used to decouple acquisition of model data from view controllers while keeping the latter updated.
* UIWebView used to display a url associated with a student object. The UIWebViewDelegate protocol is used to update the source view controller as the user navigates in the destination web view.
* Navigation is implemented using UINavigationController and UITabBarController.


## Screenshots

### Login

This view allows the user to login and gain access to the other views in the application.

![Login View Controller](/../screenshots/screenshots/OnTheMap_screenshot_Login.png?raw=true "Login View Controller")

* Enter email and password to login via a Udacity REST API.
* Login with Facebook
* Upon successful login all student location objects are immediately prefetched from Parse.
* Select "Sign Up" to create an account
* Special effect: shake animation of text field if invalid input

### Map

This view displays an annotation on a map view for each student who has recently logged into the app.

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_map.png?raw=true "Map View Controller")

* Select the Pin button to segue to the Info Posting view.
* Select the Refresh button to retrieve student data from Parse and update all annotations on the map view. 

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_map_pin_menu.png?raw=true "Map View Controller")

* Select the annotation callout accessory to see a web page associated with the selected annotation.

### Info Posting

In this view a user can enter a text description of a location, map it, add a url, and post it to Parse. The view code manages multiple view states efficiently. This allows a user to accomplish several interactions efficiently within a single view.

### Enter Location state

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_your_location.png?raw=true "Map View Controller")

In this view state the user enters a text location with the keyboard or by selcting Browse to pop up an embedded web view.

* When the "Find on the Map" button is selected the text location the user entered is forward geocoded to 2D coordinates and an annotation is displayed on the map.
* The keyboard is managed with a UITapGestureRecognizer.

### Enter URL state

In this view state the user enters a URL to associate with their data.

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_url.png?raw=true "Map View Controller")

* To aid the user in selecting a URL without having to type it in the user can select the Browse button which displays an embedded web view. 
* The web page to which the user browsed is retrieved via the UIWebViewDelegate protocol and displayed in this view.
* When the "Submit" button is selected the location and url are associated with the user and updated via the Parse API. Other users will now see this user's data in their app.

### Additional renderings of the data

## List

In this view a UITableView (rather than a map) presents a student location object in each row.

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_table.png?raw=true "Map View Controller")

* Select a row to display the url assocated with the selected object.

## Collection

In this view a UICollectionView presents a student location object in each cell.

![Map View Controller](/../screenshots/screenshots/OnTheMap_screenshot_collectionView.png?raw=true "Map View Controller")

* Like the UITableView, select a row to display the url associated with the selected object.
* A default image placeholder is displayed in each cell.



###
