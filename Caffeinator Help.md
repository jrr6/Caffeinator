# Caffeinator Help

Caffeinator is a simple menu-bar app that allows you to prevent your computer from falling asleep. 

[TOC]

## Installation

To install Caffeinator:

* Download the latest version from the [Caffeinator website](https://aaplmath.github.io/Caffeinator). 
* Open the disk image file that is downloaded.
* Drag the Caffeinator icon to the `Applications` folder.
* Once the app finishes copying, eject the disk image by dragging the Caffeinator icon on your Desktop (*not* the one you dragged to Applications) to the Trash.
* Follow the steps below to open Caffeinator for the first time.

## Opening the App

The very first time you try to launch Caffeinator (or a new version of the app), you'll get an error saying that the app is from an "untrusted developer." This is because Caffeinator is not signed with a developer certificate, which costs $99 (money that an open-source project like this doesn't have) to obtain from Apple. Therefore, you'll need to do the following the first time you open any new version of Caffeinator:

* Navigate to your `Applications` folder in Finder.
* Right-click (on a MacBook, click with two fingers) on the Caffeinator icon in Finder.
* Select `Open`.
* Confirm that you want to open the app.

Once you've opened a new version for the first time, you'll be able to open it regularly (as you would any other app on your computer) from then on. Whenever Caffeinator is open, you'll see a coffee cup icon in your menu bar.

## Opening Caffeinator on Login

If you use Caffeinator frequently, consider having it open automatically when you log in. To do so, add Caffeinator to your Login Items:

* Open System Preferences.
* Select `Users & Groups`.
* Select your user account in the left-hand sidebar, then select the `Login Items` tab on the right.
* Click the plus icon below the list of applications (not the one on the far left).
* Select Caffeinator from the list that appears and click `Add`.

## Caffeination Options

Caffeinator provides a number of different options to prevent computer sleep. These can be accessed from the main Caffeinator menu:

* Start Caffeinator: Prevents sleep until `Stop Caffeinator` is clicked. To quickly start a Caffeination, you can also right-click or <kbd>option</kbd>-click the menu bar icon.
* Caffeinate a Process: This will prevent your computer from going to sleep until a process has completed. For example, if you're presenting a PDF using a projector, enter the PID of the PDF app and your computer will wait to sleep until you quit that application. To find an application's PID, use Activity Monitor (located at `/Applications/Activity Monitor`).
* Timed Caffeination: Keeps your computer from sleeping for a defined amount of time greater than one second. Select one of the presets from the list or enter a custom time interval in seconds using the `Other...` option (note that custom time intervals must be written only as seconds, not as hours or minutes—`5400` is a valid interval, but `1:30:00` is not).
* Custom Caffeination: This allows you to create a Caffeination that stops certain types of sleep or emulates certain user processes to prevent sleep. Use the checkboxes on the left-hand side of the Custom Caffeination window to select which features you want to enable for the Caffeination; on the right-hand side, fill in the amount of time for which you want Caffeinator to prevent sleep or the PID of the process during whose lifespan you want to prevent sleep if you have selected either of the applicable options on the left side. Each of the Custom Caffeination options is described below:

  | Option               | Function                                                     |
  | -------------------- | ------------------------------------------------------------ |
  | Display Sleep        | Prevents the display from sleeping                           |
  | Idle Sleep           | Prevents the system (but not the display) from idle sleeping |
  | Disk Sleep           | Prevents the disk from idle sleeping                         |
  | System Sleep         | Prevents system sleep (on MacBooks, will only work when connected to AC power) |
  | Assert User Activity | Asserts that the user is active                              |
  | Timed                | Prevents sleep as per the options above for a specified period of time |
  | Process-Based        | Prevents sleep as per the options above as long as a specified process is active |

* Caffeinate Display: Enable if you want Caffeinator to prevent display sleep as well as computer sleep. If you do not enable this feature, your computer's screen will go to sleep after the interval specified in the System Preferences Energy Saver settings, but background processes will still continue to run. Note that if this preference is modified during an active Caffeination, you will need to start a new Caffeination for changes to take effect.

At any time, you may stop an ongoing Caffeination by pressing the Stop Caffeinator button or by right-clicking or <kbd>option</kbd>-clicking the menu bar icon.