# Bufpeek


Bufpeek is a status bar application for OS X that shows today's update list for a [Buffer](https://buffer.com/app) account. It uses [Buffer's API](https://buffer.com/developers/api) to authenticate and obtain the list of social updates.

# Features

Here is a summary of the features:

* Update's list filter by status: Pending and sent.
* Update's list filter by social network. E.g. Twitter, Facebook, etc.
* Refreshes every 2 minutes 
* Force a a refresh
* Support for dark and light menu bar themes

# Build it

Clone this repo and go inside the directory using a terminal.
Then, run the pod command:

    pod install
 
Open the project:

    open Bufpeek.xcworkspace

Run the project.


# Current limitations

The app fetches at most 100 pending updates and 100 sent updates per profile. This means that if the user has a profile with more than 100 pending or sent updates, the updates after the update number 100 won't be obtained.


# Ideas for improvement 

It's been said that there is always space for improvement, so here is a list of things that could be added in future versions.

## Features

* Add an application icon and change the current status bar icon
* Notification when an update is posted
* Widget with a summary of Today's updates
* Show a detail of an update 
* Configure the update interval
* Configure the date range for listing updates. E.g. last 3 days and the next 2 days

## Code 

Improvements related to the code and the libraries used.

* Cancel promises and requests. 
* Add unit testing (I should have added this already :))
* Functional test for API calls
https://github.com/AliSoftware/OHHTTPStubs
* UI tests. Perhaps with Xcode 7 and iOS 9

# Supported platforms

The app uses CCNStatusItem which runs only on OS X 10.10. For this reason this project will run on this version and newer.

This project is written in Swift 1.2 using Xcode 6.4.


# License and credits

This project is created by Humberto Aquino ([@goku2](https://twitter.com/goku2) on Twitter) and is under the MIT license.

Feedback is always welcome :D


