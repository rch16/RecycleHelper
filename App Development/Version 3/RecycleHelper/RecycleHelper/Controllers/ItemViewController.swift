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
    @IBOutlet weak var actionBtn: UIButton!
    @IBAction func actionBtnWasPressed(_ sender: UIButton) {}
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
    var charityShop: Bool!
    var supermarket: Bool!
    var recyclingCentre: Bool!

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
        descriptionTable.alwaysBounceVertical = false
        descriptionTable.separatorStyle = .none
        // Load and display info
        loadItemData()
        displayInfo()
        showButton()
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
    
    
    // MARK: - Displaying Information
    
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
        
        // Recyclability
        recyclable = itemInfo["Recyclable"] as? String
        if recyclable.contains("Not") {
            recycledItBtn.isHidden = true
        } else {
            recycledItBtn.isHidden = false
        }
        
        // Instructions (may not have any)
        if let how = itemInfo["How"] as? [String] {
            instructions = how
        } else {
            instructions = []
        }
        
        // Can take to a charity shop?
        if let _ = itemInfo["Charity Shop"] {
            charityShop = true
            showButton()
        } else {
            charityShop = false
        }
        
        // Can take to a supermarket?
        if let _ = itemInfo["Supermarket"] {
            supermarket = true
            showButton()
        } else {
            supermarket = false
        }
        
        // Can take to a recycling centre?
        if let _ = itemInfo["Recycling Centre"] {
            recyclingCentre = true
            showButton()
        } else {
            recyclingCentre = false
        }
    }
    
    func showButton() {
        if recyclingCentre == true {
            actionBtn.isHidden = false
            actionBtn.setTitle(K.buttonOptions[0], for: .normal)
        } else if charityShop == true {
            actionBtn.isHidden = false
            actionBtn.setTitle(K.buttonOptions[1], for: .normal)
        } else if supermarket == true {
            actionBtn.isHidden = false
            actionBtn.setTitle(K.buttonOptions[2], for: .normal)
        } else {
            actionBtn.isHidden = true
        }
    }
    
    // Show completion
    func showCompletionAlert(message: String) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func openUrl(urlStr: String!){
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    private func displayInfo(){
        if let recycle = recyclable {
            itemRecyclability.text = recycle
            if recycle == "Widely Recycled" || recycle == "Recyclable" {
                if let photo = UIImage(named: "background_can_recycle.png"){
                    imageView.image = photo
                }
            } else if recycle.contains("Local Authority") {
                if let photo = UIImage(named: "background_check.png"){
                       imageView.image = photo
                   }
            } else if recycle == "Not Recyclable" {
                if let photo = UIImage(named: "background_cant_recycle.png"){
                    imageView.image = photo
                }
            } else {
                if let photo = UIImage(named: "background_can_recycle.png"){
                       imageView.image = photo
                   }
            }
        }
    }
    
    // MARK: - UITableView Methods

    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return instructions.count
    }
    
    // Set header appearance
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat(2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = descriptionTable.dequeueReusableCell(withIdentifier: K.itemInfoCellIdentifier, for: indexPath) as? InfoTableViewCell  else {
           fatalError("The dequeued cell is not an instance of InfoTableViewCell.")
        }

        // Fetches the appropriate item for the data source layout.
        let instruction = instructions[indexPath.section]
        cell.instr.text = instruction
    
        return cell
    }
    
    // MARK: - Segue Preparation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationVC = segue.destination as? LocationViewController , segue.identifier == K.findLocationSegue {
            if let title = actionBtn.titleLabel?.text {
                if title.contains("supermarket") {
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
