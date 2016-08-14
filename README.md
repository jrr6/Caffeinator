# Caffeinator

#### Caffeinator is a simple menu-bar app that provides a visual interface for the `caffeinate` command-line tool.

Caffeinator does not use CocoaPods, Carthage, or any other dependency manager, and has no dependencies. All of the code for Caffeinator is contained within the AppDelegate file. View Releases to download a build of the latest (semi) stable release, or manually build the application in Xcode.

## FAQ

* **Why isn't there an option to specify a utility as an argument to `caffeinate` (as is shown in the manpage)?**

  Because there's really no practical benefit to it, and it would create needless hassle. If you want equivalent functionality, start the process manually, then find its PID and use process-based Caffeination.

* **Why can't I open Caffeinator?**

  Probably because Caffeinator is not signed with a Developer Certificate. To open Caffeinator the first time after installing it, right-click on the app icon and click "Open," then confirm that you trust the app.
  
* **Why are the pbxproj file and unit/UI tests missing from the source code for the release I downloaded?** 

  Several files that were previously uploaded (including the test files and .pbxproj file) contained mildly sensitive data. Therefore, several modifications had to be made to the repository, and because I'm rather inadequately versed in Git, I was forced to delete them from the releases from 1.1.0 and before (though you can create your own .xcodeproj file, and the tests and UI tests were empty anyway).

* **Why is this README so short?**

  Because Caffeinator has a website, which you can visit [here](https://aaplmath.github.io/Caffeinator).
