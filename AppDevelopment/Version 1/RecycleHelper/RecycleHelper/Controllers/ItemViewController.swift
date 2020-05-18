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
    
    
    @IBOutlet var itemView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemImageSource: UILabel!
    @IBOutlet weak var itemDescription: UITextView!
    
    var itemID: String!
    var itemList: [String: [String: Any]]!
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Read the product catalog from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: "ItemList", ofType: "plist") {
            itemList = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // rounded corners
        itemView.layer.cornerRadius = 10
        itemView.layer.masksToBounds = true
        
        if itemID != nil {
            guard itemList[itemID] != nil else {
                return
            }
            itemLabel.text = itemList[itemID]?["label"] as? String
            itemImageSource.text = itemList[itemID]?["source"] as? String
            itemDescription.text = itemList[itemID]?["description"] as? String
            if let photo = UIImage(named: itemID + ".jpg") {
                itemImage.image = photo
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
