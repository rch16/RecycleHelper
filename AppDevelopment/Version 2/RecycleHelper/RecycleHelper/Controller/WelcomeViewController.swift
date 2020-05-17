//
//  ViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 12/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//
//  Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
//

import UIKit
import AVFoundation

class WelcomeViewController: UIViewController {
    
    @IBAction func unwindLabelScanning(segue: UIStoryboardSegue) {}
    @IBAction func unwindInfoView(segue: UIStoryboardSegue) {}
    
    // Attach UI
    @IBAction func searchBtn(_ sender: UIButton) {}
    @IBAction func symbolScanBtn(_ sender: UIButton) {}
    @IBAction func objectScanBtn(_ sender: UIButton) {}
    @IBAction func infoBtn(_ sender: UIButton) {
    }
    
    let image = UIImage(systemName: "info.circle")
    let configuration = UIImage.SymbolConfiguration(scale: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Hide back button
        self.navigationItem.hidesBackButton = true
        // Change navigation bar back button appearance
        self.navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    }
    
}

