//
//  SceneDelegate.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 01/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var storyboard:UIStoryboard?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        UserDefaults.standard.register(defaults: [K.saveItemKey: []])
        UserDefaults.standard.register(defaults: [K.showFavourites: false])
        UserDefaults.standard.register(defaults: [K.binCollections: [CollectionItem]()])
        UserDefaults.standard.register(defaults: [K.hasPersonalised: false])
        UserDefaults.standard.register(defaults: [K.personalisation: ""])
        UserDefaults.standard.register(defaults: [K.lastUpdated: ""])
        UserDefaults.standard.register(defaults: [K.userLocation: ""])
        
        let launchedBefore = UserDefaults.standard.bool(forKey: K.launchedBefore)

        if launchedBefore  { // Not the first visit
            // So show the home screen
            launchStoryboard(identifier: "tab", scene: scene)
        }
        else { // First visit
            // Set "launchedBefore" to true
            UserDefaults.standard.set(true, forKey: "LaunchedBefore")
            // And show the onboarding
            launchStoryboard(identifier: "onboarding", scene: scene)

        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func launchStoryboard(identifier: String, scene: UIScene){
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard!.instantiateViewController(withIdentifier: identifier)
        //self.window?.rootViewController = navigationController
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = viewController
            self.window = window
            window.makeKeyAndVisible()
        }
        
        
    }
    
}

