//
//  SearchItemViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 18/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class ItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Attach UI
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemRecyclability: UILabel!
    @IBOutlet weak var descriptionTable: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favouriteBtn: UIBarButtonItem!
    @IBAction func favouriteDidChange(_ sender: Any) {
        // Toggle favourite status
        isFavourite.toggle()
        // Haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        // Define behaviour
        if (isFavourite) {
            favouriteBtn.image = UIImage(systemName: "star.fill")
            favouriteItems.append(itemID)
            UserDefaults.standard.set(favouriteItems, forKey: K.saveItemKey)
        } else {
            favouriteBtn.image = UIImage(systemName: "star")
            if let index = favouriteItems.firstIndex(of: itemID) {
                favouriteItems.remove(at: index)
            }
            UserDefaults.standard.set(favouriteItems, forKey: K.saveItemKey)
        }
    }
    @IBAction func learnMoreBtn(_ sender: Any) { openUrl(urlStr: "https://www.recyclenow.com/what-to-do-with") }
    
    var itemID: String!
    var itemInfo: [String: Any]!
    var recyclable: String!
    var instructions: [String]!
    var isFavourite: Bool!
    var favouriteItems: Array<String>!
    var fromFavourites: Bool!
    
    override func viewWillAppear(_ animated: Bool) {
        itemName.text = itemID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        // Make navigation bar opaque
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
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
        // Get user defaults
        getUserDefaults()
        // Check if item is favourite
        checkIfFavourite()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionTable.flashScrollIndicators()
    }
    
    func getUserDefaults() {
        favouriteItems = (UserDefaults.standard.object(forKey: K.saveItemKey) as? Array<String>)!
    }
    
    func checkIfFavourite() {
        // First, check if segue is from favourites view
        // If so, all data will be favourite
        if fromFavourites {
            isFavourite = true
            favouriteBtn.image = UIImage(systemName: "star.fill")
        } else {
            // Next, check if specific item is favourite by checking favourites list
            if let _ = favouriteItems.firstIndex(of: itemID) {
                isFavourite = true
                favouriteBtn.image = UIImage(systemName: "star.fill")
            } else {
                isFavourite = false
                favouriteBtn.image = UIImage(systemName: "star")
            }
        }
    }
    
    private func loadItemData() {
        // itemInfo loaded during segue
        recyclable = itemInfo["Recyclable"] as? String
        if let how = itemInfo["How"] as? [String] {
            instructions = how
        } else {
            instructions = []
        }
    }
    
    
    // MARK: - Displaying Information
    
    private func displayInfo(){
        if let recycle = recyclable {
            itemRecyclability.text = recycle
            if recycle == "Widely Recycled" || recycle == "Recyclable" {
                if let photo = UIImage(named: "can_recycle.png"){
                    imageView.image = photo
                }
            } else if recycle.contains("Local Authority") {
                if let photo = UIImage(named: "check.png"){
                       imageView.image = photo
                   }
            } else if recycle == "Not Recyclable" {
                if let photo = UIImage(named: "cant_recycle.png"){
                    imageView.image = photo
                }
            } else {
                if let photo = UIImage(named: "can_recycle.png"){
                       imageView.image = photo
                   }
            }
        }
    }

    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = descriptionTable.dequeueReusableCell(withIdentifier: K.itemInfoCellIdentifier, for: indexPath) as? InfoTableViewCell  else {
           fatalError("The dequeued cell is not an instance of InfoTableViewCell.")
        }

        // Fetches the appropriate item for the data source layout.
        let instruction = instructions[indexPath.row]
        cell.instr.text = instruction
        
        // Alter appearance
        cell.instr.numberOfLines = 0
        cell.instr.lineBreakMode = .byWordWrapping
        cell.instr.sizeToFit()
    
        return cell
    }
    
    func openUrl(urlStr: String!){
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}
