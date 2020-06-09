//
//  ObjectViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 30/12/2019.
//  Copyright © 2019 Becca Hallam. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
    
class ObjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Link to UI
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemRecyclability: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var infoTable: UITableView!
    @IBOutlet weak var recycledItBtn: UIButton!
    @IBAction func didRecycleIt(_ sender: UIButton) {
        // UIActionSheet
        // Show action sheet to make sure
        let optionMenu = UIAlertController(title: nil, message: "Do you want to increase your recycled item count?", preferredStyle: .actionSheet)
            
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            // Haptic feedback
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            // Get current count
            if let count = UserDefaults.standard.object(forKey: K.recycleCount) as? Int {
                // Increase count
                UserDefaults.standard.set(count + 1, forKey: K.recycleCount)
            }
            // Show completion message
            self.showCompletionAlert(message: "Count increased successfully.")

        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        optionMenu.addAction(yesAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }

    // Information for display
    var itemID: String!
    var itemList: [String: [String: Any]]!
    var itemOptions: [String]!
    var category: String!
    var instructions: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign table data source and delegate
        infoTable.dataSource = self
        infoTable.delegate = self
        
        // Alter table appearance
        infoTable.rowHeight = UITableView.automaticDimension
        infoTable.alwaysBounceVertical = false
        infoTable.separatorStyle = .none
    
        
        if let path = Bundle.main.path(forResource: "ItemList", ofType: "plist") {
            itemList = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            itemOptions = Array(itemList.keys)
            if itemID != nil {
                for item in itemOptions{
                    if item.lowercased().contains(itemID.lowercased()){
                        loadData(category: item)
                    }
                }
            }
        }
    
    }

    func loadData(category: String) {
        // Item Title
        itemName.text = itemList[category]!["label"] as? String
        // If item is recyclable or not
        if let recyclability = itemList[category]!["recyclable"] as? String {
            itemRecyclability.text = recyclability
            if recyclability == "Recyclable" {
                recycledItBtn.isHidden = false
            } else {
                recycledItBtn.isHidden = true
            }
        } else {
            recycledItBtn.isHidden = true
        }
        
        // Item instructions
        instructions = itemList[category]!["instructions"] as? [String]
        // Image
        let photoID = itemList[category]!["image"] as? String
        let ID = "background_" + photoID!
        if let photo = UIImage(named: ID){
            itemImage.image = photo
        }
        itemImage.layer.cornerRadius = 15
        itemImage.clipsToBounds = true
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = infoTable.dequeueReusableCell(withIdentifier: K.infoCellIdentifier, for: indexPath) as? InfoTableViewCell  else {
           fatalError("The dequeued cell is not an instance of InfoTableViewCell.")
        }

        // Fetches the appropriate item for the data source layout.
        let instruction = instructions[indexPath.row]
        cell.instr.text = instruction
        
        // Alter appearance
        cell.instr.numberOfLines = 0
        cell.instr.lineBreakMode = .byWordWrapping
        cell.clipsToBounds = true
    
        return cell
    }
    
    // Show completion
    func showCompletionAlert(message: String) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

