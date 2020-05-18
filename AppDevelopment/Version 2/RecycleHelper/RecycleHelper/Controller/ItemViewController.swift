//
//  ItemViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 30/12/2019.
//  Copyright © 2019 Becca Hallam. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
    
class ItemViewController: UIViewController {

    // Link to UI
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemRecyclability: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBAction func doneBtn(_ sender: UIButton) {}
    @IBAction func scanAgainBtn(_ sender: UIButton) {}

    // Information for display
    var itemID: String!
    var itemList: [String: [String: Any]]!
    var itemOptions: [String]!
    var category: String!
    
    //@IBAction func dismissView(_ sender: Any) {dismiss(animated: true)}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Read the product catalog from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: "ItemList", ofType: "plist") {
            itemList = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            itemOptions = Array(itemList.keys)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if itemID != nil {
            for item in itemOptions{
                if item.lowercased().contains(itemID){
                    category = item
                    // Item Title
                    itemName.text = itemList[category!]!["label"] as? String
                    // If item is recyclable or not
                    itemRecyclability.text = itemList[category!]!["recyclable"] as? String
                    // Image
                    let photoID = itemList[category!]!["image"] as? String
                    if let photo = UIImage(named: photoID!){
                        itemImage.image = photo
                    }
                    itemImage.contentMode = .top
                    itemImage.layer.cornerRadius = 15
                    itemImage.clipsToBounds = true
                }
            }
        }
    }
    
}

