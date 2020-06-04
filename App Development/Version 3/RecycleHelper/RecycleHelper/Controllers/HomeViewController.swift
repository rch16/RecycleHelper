//
//  HomeViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 01/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class HomeViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func unwindAddingCollection(segue: UIStoryboardSegue) {}
    @IBAction func finishAddingCollection(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? NewCollectionViewController {
            newCollection = sourceVC.newCollection
            addNewCollection(title: newCollection!.title, collectionDate: newCollection!.collectionDate, reminderDate: newCollection!.reminderDate)
        }
    }
    
    // Attach UI
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var collectionTable: UITableView!
    @IBAction func didSelectSettings(_ sender: UIBarButtonItem) {
    }
    @IBAction func didAddCollection(_ sender: UIButton) {
    }
    
    // Bin Collections Data
    private var collectionItems = [CollectionItem]()
    var datePicker: UIDatePicker = UIDatePicker()
    let toolBar = UIToolbar()
    
    // Adding new collection
    var newCollection: CollectionItem?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get user defaults
        getUserDefaults()
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        // Request push notifications access
        registerLocal()
        // Assign table data source and delegate
        collectionTable.dataSource = self
        collectionTable.delegate = self
        // Alter table appearance
        collectionTable.separatorStyle = .none
    }

    // Request permission to send user push notifications
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func getUserDefaults() {
        guard let collectionData = UserDefaults.standard.object(forKey: K.binCollections) as? Data else {
            return
        }
        
        guard let collections = try? PropertyListDecoder().decode([CollectionItem].self, from: collectionData) else {
            return
        }
        
        collectionItems = collections
     }
    
    func setDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm MMMMd")
        return dateFormatter
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(K.cellSpacingHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell using a cell identifier
        guard let cell = collectionTable.dequeueReusableCell(withIdentifier: K.collectionCellIdentifier, for: indexPath) as? CollectionTableViewCell else { fatalError("The dequeued cell is not an instance of CollectionTableViewCell") }
        
        // Edit cell appearance here
        let item = collectionItems[indexPath.row]
        let df = setDateFormatter()
        let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
        
        cell.collectionTitle.text = item.title
        cell.collectionDate.text = df.string(from: item.collectionDate)
        cell.accessoryType = accessory
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = collectionItems[indexPath.row]
        item.done = !item.done
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func addNewCollection(title: String, collectionDate: Date, reminderDate: Date) {
        // The index of the new item will be the current item count
        let newIndex = collectionItems.count

        // Create new item and add it to the collections list
        collectionItems.append(CollectionItem(title: title, collectionDate: collectionDate, reminderDate: reminderDate))
        
        // Update user defaults
        UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)

        // Tell the table view a new row has been created
        self.collectionTable.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
}

