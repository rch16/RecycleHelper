//
//  SearchItemViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 18/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class SearchItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemRecyclability: UILabel!
    @IBOutlet weak var descriptionTable: UITableView!
    @IBAction func learnMoreBtn(_ sender: Any) { openUrl(urlStr: "https://www.recyclenow.com/what-to-do-with") }
    
    var itemID: String!
    var tableData: [String: [String: Any]]!
    var itemInfo: [String: Any]!
    var recyclable: String!
    var instructions: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        itemName.text = itemID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Assign table data source and delegate
        descriptionTable.dataSource = self
        descriptionTable.delegate = self
        // Alter table appearance
        descriptionTable.rowHeight = UITableView.automaticDimension
        descriptionTable.alwaysBounceVertical = false
        descriptionTable.separatorStyle = .none
        // Load and display info
        loadItemData()
        displayInfo()
        // Remove lines between table entries
        //self.tableView.separatorColor = UIColor(cgColor: .clear)
    }
    
    private func loadItemData() {
        // Read from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: K.searchData, ofType: "plist") {
            tableData = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            itemInfo = tableData[itemID]
            recyclable = itemInfo["Recyclable"] as? String
            instructions = itemInfo["How"] as? [String]
        }
    }
    
    // MARK: - Displaying Information
    
    private func displayInfo(){
        itemRecyclability.text = recyclable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        descriptionTable.deselectRow(at: indexPath, animated: true)
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = descriptionTable.dequeueReusableCell(withIdentifier: K.itemInfoCellIdentifier, for: indexPath) as? ItemInfoTableViewCell  else {
           fatalError("The dequeued cell is not an instance of ItemInfoTableViewCell.")
        }

        // Fetches the appropriate item for the data source layout.
        let instruction = instructions[indexPath.row]
        cell.instr.text = instruction
        
        // Alter appearance
        cell.instr.numberOfLines = 0
        cell.instr.lineBreakMode = .byWordWrapping
        cell.instr.sizeToFit()
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor(rgb: 0xCCEDD2).cgColor
        
        return cell
    }
    
    func openUrl(urlStr: String!){
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}
