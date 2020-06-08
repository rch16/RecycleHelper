//
//  SymbolInfoViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 03/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

class SymbolInfoViewController: UIViewController {

    // Attach UI
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var symbolName: UILabel!
    @IBOutlet weak var symbolFullName: UILabel!
    @IBOutlet weak var symbolInfo: UILabel!
//    @IBOutlet weak var symbolExamples: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var recycleLabel: UILabel!
    
    // Symbol Data
    var symbolID: String!
    var category: String!
    var symbolData: [String: [String: Any]]!
    var charityShop: Bool!
    var collectionPoint: Bool!
    var recyclingCentre: Bool!
    
    override func viewWillAppear(_ animated: Bool) {
        symbolName.text = symbolID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make navigation bar opaque
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Load data
        loadSymbolData()
    }
    
    func loadSymbolData() {
        
        // Reset variables
        charityShop = false
        collectionPoint = false
        recyclingCentre = false
    
        let info = (symbolData[symbolID] as? [String: Any])!
        
        // Full name
        if let fullName = info["FullName"] {
            symbolFullName.text = fullName as? String
        } else {
            symbolFullName.text = nil
        }
        
        // Recycle?
        if let recyclablility = info["Recyclable"] as? String {
            recycleLabel.text = recyclablility
        } else {
            recycleLabel.text = nil
        }
        
        // Information
        if let info = info["About"] as? String {
            if info.contains("charity") {
                // show charity shop button
                charityShop = true
                showButton()
            } else if info.contains("collection point") {
                // show collection point button
                collectionPoint = true
                showButton()
            } else if info.contains("centre") {
                // show recycling centre button
                recyclingCentre = true
                showButton()
            } else {
                // hide button
                actionBtn.isHidden = true
            }
        } else {
            // hide button
            actionBtn.isHidden = true
        }
        symbolInfo.text = info["About"] as? String
        
        // Symbol
        if let name = info["Image"] as? String {
            let imageName = "background_" + name
            if let picture = UIImage(named: imageName){
                 imageView.image = picture
             }
        } else {
            imageView.image = UIImage(named: "circle_background.png" )
        }
        
        // Examples
//        if let examples = info["Examples"] {
//            symbolExamples.text = examples as? String
//        } else {
//            symbolExamples.text = nil
//        }

    }
    
    func showButton() {
         if recyclingCentre == true {
             actionBtn.isHidden = false
             actionBtn.setTitle(K.buttonOptions[0], for: .normal)
         } else if charityShop == true {
             actionBtn.isHidden = false
             actionBtn.setTitle(K.buttonOptions[1], for: .normal)
         } else if collectionPoint == true {
             actionBtn.isHidden = false
             actionBtn.setTitle(K.buttonOptions[3], for: .normal)
         } else {
             actionBtn.isHidden = true
         }
     }
    
    // MARK: - Segue Preparation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationVC = segue.destination as? LocationViewController , segue.identifier == K.showLocationSegue {
            if let title = actionBtn.titleLabel?.text as? String {
                if title.contains("collection point") {
                    locationVC.showIndex = 2
                } else if title.contains("charity") {
                    locationVC.showIndex = 1
                } else {
                    locationVC.showIndex = 0
                }
            }
        }
    }

}
