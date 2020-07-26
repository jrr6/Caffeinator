# Caffeinator Help

Caffeinator is a simple menu-bar app that helps you prevent your computer from falling asleep. 

[TOC]

## Installation

To install Caffeinator:

* Download the latest version from the [Caffeinator website](https://aaplmath.github.io/Caffeinator). 
* Open the downloaded disk image file.
* Drag the Caffeinator icon to the `Applications` folder.
* Once the app finishes copying, eject the disk image by dragging the Caffeinator icon on your Desktop (*not* the one you dragged to Applications) to the Trash.
* Follow the steps below to open Caffeinator for the first time.

## Opening the App

The very first time you try to launch Caffeinator, you'll get an error saying that the app is from an "untrusted developer." This is because Caffeinator is not signed with a developer certificate, which costs $99 (money that an open-source project like this doesn't have) to obtain from Apple. Therefore, you'll need to do the following the first time you open Caffeinator:

* Navigate to your `Applications` folder in Finder.
* Right-click (on a MacBook, click with two fingers) on the Caffeinator icon in Finder.
* Select `Open`.
* Confirm that you want to open the app.

Once you've opened a new version for the first time, you'll be able to open it regularly (as you would any other app on your computer) from then on. Whenever Caffeinator is open, you'll see a coffee cup icon in your menu bar. When the coffee cup is green, Caffeinator is keeping your computer awake.

For convenience, you can also have Caffeinator unobtrusively and automatically appear in your menu bar whenever you log in by following the steps below.

## Opening Automatically at Login

If you use Caffeinator frequently, consider having it open automatically when you log in. To do so, add Caffeinator to your Login Items:

* Open System Preferences.
* Select `Users & Groups`.
* Select your user account in the left-hand sidebar, then select the `Login Items` tab on the right.
* Click the plus icon below the list of applications (not the one on the far left).
* Select Caffeinator from the list that appears, and click `Add`.

## Caffeination Options

Caffeinator provides a number of different options to prevent computer sleep. These are listed below and can be accessed from the main Caffeinator menu. At any time, you may stop an ongoing Caffeination by pressing the Stop Caffeinator button or by right-clicking or <kbd>option</kbd>-clicking the menu bar icon.

* Start Caffeinator: Prevents sleep until `Stop Caffeinator` is clicked. To quickly start a Caffeination, you can also right-click or <kbd>option</kbd>-click the menu bar icon.

* Caffeinate a Process: This will prevent your computer from going to sleep until a process has completed. For example, if you're presenting a PDF using a projector, select the app you're using to display the PDF and your computer will wait to sleep until you quit that application. To select an app, use the dropdown selector under "Select Process" or choose "Enter PID" to manually enter the identifier of a running process. To find an application's PID, use Activity Monitor (located at `/Applications/Activity Monitor`). If you need to Caffeinate a system daemon or other background process that doesn't appear in the standard dropdown, consider enabling `Use Advanced Process Selector`.

* Timed Caffeination: Keeps your computer from sleeping for a defined amount of time greater than one second. Select one of the presets from the list or enter a custom time interval in hours, minutes, and seconds using the `Other…` option.

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

* Use Advanced Process Selector: This option shows all running processes (rather than just apps and helpers) in the `Caffeinate a Process` selector. Select this option if you need to Caffeinate command-line tools, system daemons, or other non-app-bundle processes.

## Assigning Keyboard Shortcuts

Caffeinator allows you to map global keyboard shortcuts to commonly used Caffeinations (regular, process-based, time-based, and custom). Shortcuts allow you to quickly start a Caffeination simply by pressing a key combination on your keyboard.

By default, no keyboard shortcuts are configured. To view the keyboard shortcut configuration window, select `Advanced` > `Configure Keyboard Shortcuts…` in the Caffeinator menu. The window displays any existing shortcuts and allows you to change or remove them or configure new ones.

To define a new shortcut:

* Click the `Set` button next to the Caffeination type whose shortcut you'd like to configure. The `Set` button will turn blue, indicating that Caffeinator is "listening" for a shortcut entry. 
* On your keyboard, press the shortcut you'd like to assign. To minimize conflicts with everyday tasks, Caffeinator requires that this shortcut contain at least one of <kbd>control</kbd>, <kbd>option</kbd>, <kbd>command</kbd>, or the function keys.

To update an existing shortcut, follow the steps above, but note that the `Set` button will display the existing shortcut rather than the word "Set."

To clear an existing shortcut, click `Clear` next to the shortcut you'd like to remove.

## Automation and Scripting

Caffeinator supports automation via AppleScript and JavaScript for Automation. Using these technologies, you can start or stop a Caffeination, or observe the status and configuration of an ongoing one, from within your own custom automation scripts. For more information about Caffeinator's scripting support, review the documentation in Caffeinator's scripting dictionary (accessible in Script Editor under `File` > `Open Dictionary…` > `Caffeinator`).