# Description

Uber clone app written for iOS 11. Mimics many features of Uber to learn about the source code and how to implement various features. Learned to interact with Firebase server, communicate between users and drivers with notifications and geomap features.

##  Steps to install and build the app

* Created new project in the firebase console
* Download plist file into xcode project
* Run cocoapods to add pod 'Firebase/Core' and install
* Connect Firebase to the app in the AppDelegate class:

```

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
-> Bool {
FirebaseApp.configure()
return true
}
}

```

* Import FirebaseAuth to enable login and sign up features
* Import FirebaseDatabase to store driver and rider locations and requests
