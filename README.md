1# OnTheMap
IOS App that lets Udacity students share their location and URL
*** Login View ***

1. Does the app have a login view that accepts email and password strings from users, with a “login” button?
The app has a login page that accepts email and password strings from users, with a “Login” button. The login page also includes a “Login Using Facebook” option.
ok

2. Does the app notify the user if the login fails?
The app uses an Alert View Controller to notify the user if the login connection fails. It differentiates between a failure to connect, and an incorrect email and password. Interesting graphic design and animation built into the view are used to notify the user in case of login failure. 
ok

3. Is the login code that uses the Udacity API placed outside of the view controller?
The networking code related to login is located in a dedicated API client class. The class uses closures for completion and error handling.
ok 

4. Is the JSON handling code that uses the Parse API placed outside of the view controller?
The JSON parsing code related to student data is located  in a dedicated API client class. The class uses closures for completion and error handling.
ok

5. Does the app display an alert view if the post fails?
The user sees an alert if the post fails.
ok

*** Student Locations Tabbed View ***

1. Does the app download locations and links previously posted by students?
(to be displayed in the Map and Table tabs)
The app downloads more than the most recent 100 locations posted by students in a network-conscious manner, e.g., by using the Parse API's limits/skip parameters.
ok (the table view loads a new page of 100 rows when the row lies in the next page.

2. Does the app contain a StudentInformation struct to store individual locations and links downloaded from the service?
The app contains a StudentInformation struct with appropriate properties for locations and links.
ok

3. Does the StudentInformation struct have an init method to initialize instances from a dictionary?
The struct has an init() method that accepts a dictionary as an argument.
ok

4. Does the app store the array of StudentInformation structs in a single location, outside of the view controllers?
The StudentInformation structs are stored as an array (or other suitable data structure) inside a separate model class.
ok

5. Does the app display an alert view if the download fails?
The app displays an alert if the download fails. The app distinguishes between a failure on the server side and a lack of network connectivity in its alert
ok

6. Does the app display the downloaded data in a tabbed view with two tabs: a map and a table?
The app displays downloaded data in a tabbed view with a map and a table. The app contains additional tabs with other representations of the data.
ok

7. Does the map view contain a pin for each of the locations that were downloaded?
The map view has a pin for each student in the correct location.
ok

8. When the pins in the map are tapped, is a pin annotation displayed with the student’s name and the link that the student posted?
Tapping the pins shows an annotation with the student's name and the link the student posted.
ok

9. If the pin annotation is tapped, is the link opened in Safari?
Tapping a student’s pin annotation opens the default device browser to the student’s link.
ok

10. Does the table view contain a row for each student location that was downloaded with the student’s name displayed?
The table has a row for each downloaded record with the student’s name displayed.
ok

11. Is the Table appropriately sorted?
The table is sorted in order of most recent to oldest update.
ok (sorted in Parse get locations call, order parameter)

12. When a row in the table is tapped, does the app open Safari to the student’s link?
Tapping a row in the table opens the default device browser to the student's link.
ok

13. Does the Student Locations Tabbed View have a pin button in the upper right corner of the navigation bar? Does that button allow users to post their own information to the server?
The Student Locations Tabbed View has a pin button in the upper right corner of the navigation bar. The button modally presents the Information Posting View so that users can post their own information to the server.
ok

14. Does the Student Locations Tabbed View have a logout button in the upper left corner of the navigation bar? Does that button allow the users to correctly logout?
The Student Locations Tabbed View has a logout button in the upper left corner of the navigation bar. The logout button causes the Student Locations Tabbed View to dismiss, and logs out of the current session. If applicable, the logout button logs out of the current Facebook session.
ok

*** Information Posting View ***

1. Does this view prompt the user to enter a string representing their location? Does it provide a place for the user to enter a string?
The Information Posting view clearly indicates that the user should enter a location. The text view or text field where the location string should be typed is clearly present.
ok

2. Does the app allow users to enter a URL to be included with their location?
The app allows users to add a URL to be included with their location. The app provides a mechanism for users to browse to the link that they would like to include.
ok

3. Does the app provide a button that the user can tap to post the information to the server?
The app provides a readily accessible "Submit" button that the user can tap to post the information to the server.
ok

4. Does the app geocode an address string when a button is pressed?
When a "Submit" button is pressed, the app invokes the geocode address string on CLGeocoder with a completion block that stores the resulting latitude and longitude.
ok

5. Does the app indicate activity during the geocoding?
The app shows additional indications of activity, such as modifying alpha/transparency of interface elements.
ok (activity indicator and alpha value of the field is labels are set)

6. Does the app show the geocoded response on a map?
The app zooms the map into an appropriate region.
The app shows a placemark on a map via the geocoded response.
ok

7. Does the app post the search string and coordinates to the RESTful service?
The app successfully encodes the data in JSON and posts the search string and coordinates to the RESTful service.
ok

8. Does the app provide a button that the user can tap to cancel (dismiss) the Information Posting View?
The app provides a readily accessible button that the user can tap to cancel (dismiss) the Information Posting View.
ok
