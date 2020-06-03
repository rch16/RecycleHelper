//
//  SymbolInfoViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 03/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class SymbolInfoViewController: UIViewController {

    // Attach UI
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var symbolName: UILabel!
    @IBOutlet weak var symbolFullName: UILabel!
    @IBOutlet weak var symbolInfo: UILabel!
    @IBOutlet weak var symbolExamples: UILabel!
    
    var symbolID: String!
    var category: String!
    var data: [String: [String: Any]]!
    var symbolData: [String: Any]!
    
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
        // Read from plist file
        if let path = Bundle.main.path(forResource: K.symbolData, ofType: "plist") {
            let url = URL(fileURLWithPath: path)
            data = NSDictionary(contentsOf: url) as? [String: [String: Any]]
            symbolData = data[category]
            let info: NSDictionary = (symbolData[symbolID] as? NSDictionary)!
            // Full name
            if let fullName = info["FullName"] {
                symbolFullName.text = fullName as? String
            } else {
                symbolFullName.text = nil
            }
            // Information
            symbolInfo.text = info["About"] as? String
            // Symbol
            let imageName = info["Image"] as? String
            if let picture = UIImage(named: imageName!){
                 imageView.image = picture
             }
            // Examples
            if let examples = info["Examples"] {
                symbolExamples.text = examples as? String
            } else {
                symbolExamples.text = nil
            }
        }
    }

}
