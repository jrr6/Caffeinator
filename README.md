# Caffeinator

**Caffeinator is a simple menu-bar app that provides a visual interface for the `caffeinate` command-line tool.**

## Download

To download a prebuilt version of the latest stable release of Caffeinator, visit [Releases](https://www.github.com/aaplmath/Caffeinator/releases).

## Build

Caffeinator is built upon the [CaffeineKit](https://github.com/aaplmath/CaffeineKit) framework (which you should definitely check out!). Caffeinator uses [Carthage](https://github.com/Carthage/Carthage) to manage this and other dependencies. To build Caffeinator from source, clone this repository and run `carthage bootstrap --platform macOS --cache-builds` in the cloned directory. After doing so, open, build, and run the project in Xcode.

## FAQ

* **Why can't I open Caffeinator?**

  Probably because Caffeinator is not signed with a Developer Certificate. To open Caffeinator the first time after installing or updating it, right-click on the app icon and click "Open," then confirm that you trust the app.

* **Why isn't there an option to specify a utility as an argument to `caffeinate` (as is shown in the man page)?**

  Because there's really no practical benefit to it, and it would create needless hassle. If you want equivalent functionality, start the process manually, then find its PID and use process-based Caffeination.

* **Why can't I start a timed Caffeination for a period of time shorter than one second?**

  Firstly, there isn't really any practical use for doing this. Secondly, the `caffeinate` utility will not accept time values shorter than one second. (If you specify a time shorter than one second using the argument editor, you'll see that it runs indefinitely.)

* **How do I disable automatic update checks?**

  Caffeinator is actively developed and new updates that add new features, increase stability, and patch bugs are frequently released. It is, therefore, *not* recommended to disable the automatic update check feature. Auto-update checks run silently in the background, and by default, selecting "Not Now" when presented with an update will suspend update prompts for three days. However, if it is absolutely necessary to disable auto-update functionality, this can be achieved by setting the `DisableAutoUpdate` user defaults key to `true`. In Terminal, execute `defaults write com.aaplmath.Caffeinator DisableAutoUpdate -bool YES`, then restart Caffeinator. When auto-updating is disabled, Caffeinator presents a warning indicating that this is the case whenever the app is launched. To re-enable automatic updates, set `DisableAutoUpdate` to `false`: execute `defaults write com.aaplmath.Caffeinator DisableAutoUpdate -bool NO` in Terminal, then restart Caffeinator.

* **How do I change the frequency of automatic update checks?**
  
  This is a feature that might appear in a more fully-baked form in a later release. As it is, the daily update checks are unobtrusive and occur silently in the background. However, if you must change the frequency of update checks, you can do so with the `AutoUpdateInterval` user defaults value. To set a custom update frequency, execute `defaults write com.aaplmath.Caffeinator AutoUpdateInterval [frequency]`, where `[frequency]` is an integer or decimal value representing the desired frequency of update checks, in days (e.g., to set automatic update checks to occur once a week, run `defaults write com.aaplmath.Caffeinator AutoUpdateInterval 7`). To delete a custom value and return to the default daily update checks, execute `defaults delete com.aaplmath.Caffeinator AutoUpdateInterval` in Terminal. After executing either of these commands, you'll need to restart Caffeinator for your changes to take effect. Note that update checks occur only while the app is running and the check interval reinitiates every time the app is launched.
  
* **Why did you write your own updater?**

    Because Caffeinator isn't code-signed, automatic updates like those performed by most third-party frameworks would create headaches for users who would see errors every time a new version auto-launched. Caffeinator's more involved update process ensures that users authorize Caffeinator updates to run immediately, avoiding this confusion.

* **Why is this README so short?**

  Because Caffeinator has a website, which you can visit [here](https://aaplmath.github.io/Caffeinator).
