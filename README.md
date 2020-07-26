<img src="https://github.com/aaplmath/Caffeinator/raw/master/Caffeinator/Assets.xcassets/AppIcon.appiconset/icon_512x512%402x.png" height="150" align="left">

# Caffeinator

**Caffeinator is a menu-bar app that helps you prevent your Mac from falling asleep. It's a simple but robust visual interface for the `caffeinate` command-line tool.**

## Download

To download a prebuilt version of the latest stable release of Caffeinator, visit [Releases](https://www.github.com/aaplmath/Caffeinator/releases).

## Build

Caffeinator is built upon the [CaffeineKit](https://github.com/aaplmath/CaffeineKit) framework, which provides elegant Swift abstractions for interacting with `caffeinate`. Caffeinator uses [Carthage](https://github.com/Carthage/Carthage) to manage this and other dependencies. To build Caffeinator from source, clone this repository and run `carthage bootstrap --platform macOS --cache-builds` in the cloned directory. After doing so, open, build, and run the project in Xcode.

## FAQ

* **Why can't I open Caffeinator?**

  Probably because Caffeinator is not signed with a Developer Certificate. To open Caffeinator for the first time after installation, right-click on the app icon and click "Open," then confirm that you trust the app.

* **Why isn't there an option to specify a utility as an argument to `caffeinate` (as is shown in the man page)?**

  Because there's really no practical benefit to it, and it would create needless hassle. If you want equivalent functionality, start the process manually, then find its PID and use process-based Caffeination.

* **Why can't I start a timed Caffeination for a period of time shorter than one second?**

  Firstly, there isn't really any practical use for doing this. Secondly, the `caffeinate` utility will not accept time values shorter than one second. (If you specify a time shorter than one second using the argument editor, you'll see that it runs indefinitely.)

* **Why is this README so short?**

  Because Caffeinator has a website, which you can visit [here](https://aaplmath.github.io/Caffeinator) and which also contains a [help guide](https://aaplmath.github.io/Caffeinator/help.html).
