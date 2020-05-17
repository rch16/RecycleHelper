//
//  InfoViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 17/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    
    @IBAction func exitBtn(_ sender: Any) {}
    @IBAction func showOnboardingBtn(_ sender: Any) {}
    
    override func viewDidLoad() {
        // Make navigation bar transparent
         self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
         self.navigationController?.navigationBar.shadowImage = UIImage()
         self.navigationController?.navigationBar.isTranslucent = true
         // Hide back button
         self.navigationItem.hidesBackButton = true
    }
}
