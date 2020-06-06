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
        
        // Hide back bar button and create a custom one
//        self.navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ObjectViewController.back(sender:)))
//        self.navigationItem.leftBarButtonItem = newBackButton
        
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
    
//    @objc func back(sender: UIBarButtonItem) {
//        _ = navigationController?.popViewController(animated: true)
//    }
//
    func loadData(category: String) {
        // Item Title
        itemName.text = itemList[category]!["label"] as? String
        // If item is recyclable or not
        itemRecyclability.text = itemList[category]!["recyclable"] as? String
        // Item instructions
        instructions = itemList[category]!["instructions"] as? [String]
        // Image
        let photoID = itemList[category]!["image"] as? String
        if let photo = UIImage(named: photoID!){
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
//        cell.instr.sizeToFit()
    
        return cell
    }
}

