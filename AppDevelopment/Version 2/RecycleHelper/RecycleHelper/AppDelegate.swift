//
//  AppDelegate.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 30/12/2019.
//  Copyright © 2019 Becca Hallam. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var storyboard:UIStoryboard?
    var hasAlreadyLaunched: Bool!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window =  UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

        if launchedBefore  {
            // Not the first visit, so show the home screen
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard!.instantiateViewController(withIdentifier: "welcome")

            if let window = self.window {
                window.rootViewController = rootController
            }

        }
        else {
            // First visit, set "launchedBefore" to true
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            // And show the onboarding
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard!.instantiateViewController(withIdentifier: "onboarding")

            if let window = self.window {
                window.rootViewController = rootController
            }
        }

        return true
//        // Override point for customization after application launch.
//        // Configure Firebase
//        FirebaseApp.configure()
//        // Variable to track if app has already been launched (for onboarding flow)
//        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
//        print(hasAlreadyLaunched)
//        // Check if first launch
//        if (hasAlreadyLaunched) {
//            hasAlreadyLaunched = true
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialVC = storyboard.instantiateViewController(withIdentifier: "onboarding")
//            self.window?.rootViewController = initialVC
//            self.window?.makeKeyAndVisible()
//        } else {
//            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialVC = storyboard.instantiateViewController(withIdentifier: "welcome")
//            self.window?.rootViewController = initialVC
//            self.window?.makeKeyAndVisible()
//        }
//
//        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func setHasAlreadyLaunched(){
        hasAlreadyLaunched = true
    }
}
