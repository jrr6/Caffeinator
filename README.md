# Caffeinator

#### Caffeinator is a simple menu-bar app that provides a visual interface for the `caffeinate` command-line tool.

Caffeinator does not use CocoaPods, Carthage, or any other dependency manager, and has no dependencies. All of the code for Caffeinator is contained within the AppDelegate file. View Releases to download a build of the latest (semi) stable release, or manually build the application in Xcode.

## FAQ

* **Why isn't there an option to specify a utility as an argument to `caffeinate` (as is shown in the manpage)?**

  Because there's really no practical benefit to it, and it would create needless hassle. If you want equivalent functionality, start the process manually, then find its PID and use process-based Caffeination.

* **Why can't I open Caffeinator?**

  Probably because Caffeinator is not signed with a Developer Certificate. To open Caffeinator the first time after installing it, right-click on the app icon and click "Open," then confirm that you trust the app.
