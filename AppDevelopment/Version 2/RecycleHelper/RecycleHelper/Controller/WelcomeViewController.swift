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
    }
    
    // Attach UI
    @IBAction func searchBtn(_ sender: UIButton) {}
    @IBAction func symbolScanBtn(_ sender: UIButton) {
        performSegue(withIdentifier: K.scanLabelSegue, sender: self)
    }
    @IBAction func objectScanBtn(_ sender: UIButton) {}
   
    
}

