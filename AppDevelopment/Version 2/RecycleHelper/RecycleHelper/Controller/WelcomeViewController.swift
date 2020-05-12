//
//  ViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 12/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import UIKit
import AVFoundation

class WelcomeViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure navigation bar is transparent
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
    }
    
    // Attach UI
    @IBAction func searchBtn(_ sender: UIButton) {}
    @IBAction func symbolScanBtn(_ sender: UIButton) {}
    @IBAction func objectScanBtn(_ sender: UIButton) {}
   
    
}

