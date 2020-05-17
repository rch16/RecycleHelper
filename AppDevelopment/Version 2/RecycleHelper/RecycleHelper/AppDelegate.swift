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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure() 
        
        window =  UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "LaunchedBefore")

        if launchedBefore  { // Not the first visit
            // So show the home screen
            launchStoryboard(identifier: "welcome")
        }
        else { // First visit
            // Set "launchedBefore" to true
            UserDefaults.standard.set(true, forKey: "LaunchedBefore")
            // And show the onboarding
            launchStoryboard(identifier: "onboarding")
            
        }

        return true
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
    
    func launchStoryboard(identifier: String){
        let viewController = storyboard!.instantiateViewController(withIdentifier: identifier)
        let navigationController = UINavigationController.init(rootViewController: viewController)
        //self.window?.rootViewController = navigationController
        if let window = self.window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
