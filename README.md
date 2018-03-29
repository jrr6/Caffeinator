# Caffeinator

#### Caffeinator is a simple menu-bar app that provides a visual interface for the `caffeinate` command-line tool.

Caffeinator does not use CocoaPods, Carthage, or any other dependency manager, and has no dependencies. View [Releases](https://www.github.com/aaplmath/Caffeinator/releases) to download a build of the latest (semi) stable release, or manually build the application in Xcode.

## FAQ

* **Why can't I open Caffeinator?**

Probably because Caffeinator is not signed with a Developer Certificate. To open Caffeinator the first time after installing or updating it, right-click on the app icon and click "Open," then confirm that you trust the app.

* **Why isn't there an option to specify a utility as an argument to `caffeinate` (as is shown in the man page)?**

Because there's really no practical benefit to it, and it would create needless hassle. If you want equivalent functionality, start the process manually, then find its PID and use process-based Caffeination.

* **Why can't I start a timed Caffeination for a period of time shorter than one second?**

Firstly, there isn't really any practical use for doing this. Secondly, the `caffeinate` utility will not accept time values shorter than one second. (If you specify a time shorter than one second using the argument editor, you'll see that it runs indefinitely.)

* **How do I disable auto-updates?**

Caffeinator is actively developed and new updates that add new features, increase stability, and patch bugs are frequently released. It is therefore *not* recommended to disable the auto-update feature. Auto-update checks run silently in the background, and by default, selecting "Not Now" when presented with an update will suspend update prompts for three days. However, if it is absolutely necessary to disable auto-update functionality, this can be achieved by setting the `DisableAutoUpdate` user defaults key to `true`. In Terminal, execute `defaults write com.aaplmath.Caffeinator DisableAutoUpdate -bool YES`, then restart Caffeinator.

* **Why is this README so short?**

  Because Caffeinator has a website, which you can visit [here](https://aaplmath.github.io/Caffeinator).
