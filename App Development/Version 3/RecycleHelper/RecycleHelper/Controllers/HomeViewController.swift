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
import SwipeCellKit

class HomeViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func unwindAddingCollection(segue: UIStoryboardSegue) {}
    @IBAction func finishAddingCollection(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? NewCollectionViewController {
            if sourceVC.editCollection {
                // Overwrite edited collection
                editCollection = sourceVC.newCollection
                updateCollection(section: sourceVC.collectionIndexPathSection!, title: editCollection!.title, collectionDate: editCollection!.collectionDate, reminderDate: editCollection!.reminderDate, recurring: editCollection!.recurring)
            } else {
                // Add new collection
                newCollection = sourceVC.newCollection
                addNewCollection(title: newCollection!.title, collectionDate: newCollection!.collectionDate, reminderDate: newCollection!.reminderDate, recurring: newCollection!.recurring)
            }
        }
    }
    @IBAction func finishedEditingSettings(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SettingsViewController {
            userName.text = "Welcome, " + sourceVC.userName
        }
    }
    
    // Attach UI
    @IBOutlet weak var userName: CLTypingLabel!
    @IBOutlet weak var collectionTable: UITableView!
    @IBAction func didSelectSettings(_ sender: UIBarButtonItem) {
    }
    @IBAction func didAddCollection(_ sender: UIButton) {
    }
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func didPressEdit(_ sender: UIButton) {
        if(collectionTable .isEditing){
            // If already in edit mode, turn it off
            editBtn.setTitle("Edit", for: .normal)
            collectionTable.setEditing(false, animated: true)
        } else {
            // Enter edit mode
            editBtn.setTitle("Done", for: .normal)
            collectionTable.setEditing(true, animated: true)
        }
    }
    
    // Bin Collections Data
    private var collectionItems = [CollectionItem]()
    var noDataLabel: UILabel!
    var datePicker: UIDatePicker = UIDatePicker()
    let toolBar = UIToolbar()
    var newCollection: CollectionItem?  // Adding new collection
    var editCollection: CollectionItem?  // Editing collection
    let manager = LocalNotificationManager() // Managing push notifications

  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check personalisation
        checkPersonalisation()
        // Get user defaults
        getUserDefaults()
        // Navigation bar appearance
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // Assign table data source and delegate
        collectionTable.dataSource = self
        collectionTable.delegate = self
        // Alter table appearance
        collectionTable.separatorStyle = .none
    }
    
    func checkPersonalisation() {
        guard let hasPersonalised = UserDefaults.standard.object(forKey: K.hasPersonalised) as? Bool else {
            return
        }
        
        if !hasPersonalised {
            // Offer personalisation option
            let alert = UIAlertController(title: "Welcome to RecycleHelper!", message: "What's your name?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Input your name here..."
            })

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

                if let personalisation = alert.textFields?.first?.text {
                    self.userName.text = "Welcome, " + personalisation
                    UserDefaults.standard.set(personalisation, forKey: K.personalisation)
                }
            }))

            self.present(alert, animated: true)

            // Update user defaults
            UserDefaults.standard.set(true, forKey: K.hasPersonalised)
            
        } else {
            // Load personalisations
            guard let personalisation = UserDefaults.standard.object(forKey: K.personalisation) as? String else {
                return
            }
            userName.text = "Welcome, " + personalisation
        }
    }

    // Get previous user data
    func getUserDefaults() {
        guard let collectionData = UserDefaults.standard.object(forKey: K.binCollections) as? Data else {
            return
        }
        
        guard let collections = try? PropertyListDecoder().decode([CollectionItem].self, from: collectionData) else {
            return
        }
        
        collectionItems = collections
     }
    
    // Date format
    func setDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        //dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm MMMMd")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        return dateFormatter
    }
    
    // Add new collection
    func addNewCollection(title: String, collectionDate: Int, reminderDate: Date, recurring: Bool) {
        // The index of the new item will be the current item count
        let newIndex = collectionItems.count

        // Create new item and add it to the collections list
        collectionItems.append(CollectionItem(title: title, collectionDate: collectionDate, reminderDate: reminderDate, recurring: recurring))
        
        // Update user defaults
        UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)

        // Tell the table view a new row has been created
        self.collectionTable.insertSections([newIndex], with: .top)

        // Schedule notification
        let notificationTitle = "Collection Reminder: " + title
        let notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        manager.notifications.append(Notification(id: title, title: notificationTitle, datetime: notificationDateComponents, recurring: recurring))
        manager.schedule()
    }
    
    // Edit current colleciton
    func updateCollection(section: Int, title: String, collectionDate: Int, reminderDate: Date, recurring: Bool) {
        let indexPath = IndexPath(row: 0, section: section)
        
        // Update list
        let item = CollectionItem(title: title, collectionDate: collectionDate, reminderDate: reminderDate, recurring: recurring)
        collectionItems[indexPath.section] = item
        
        // Update cell
        if let cell = collectionTable.cellForRow(at: indexPath) as? CollectionTableViewCell {
            // Delete old notification
            manager.deleteNotification(id: cell.collectionTitle.text!)
            // Update cell
            cell.collectionTitle.text = title
            cell.collectionDate.text = K.weekdaysFromDateComponent[collectionDate]
            if(item.recurring){
                cell.repeatBtn.tintColor = UIColor(hexString: K.secondColour)
            } else {
                cell.repeatBtn.tintColor = .clear
            }
        }
        
        // Update user defaults
        UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)
        
        // Schedule new notification
        let notificationTitle = "Collection Reminder: " + title
        let notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        manager.notifications.append(Notification(id: title, title: notificationTitle, datetime: notificationDateComponents, recurring: recurring))
        manager.schedule()
   
    }
    
    func noData(message: String) {
        noDataLabel = UILabel(frame: CGRect(x: 30, y: 300, width: self.collectionTable.bounds.size.width, height: collectionTable.bounds.size.height))
        noDataLabel.text = message
        noDataLabel.textColor = .secondaryLabel
        noDataLabel.textAlignment = .center
        noDataLabel.contentMode = .top
        collectionTable.backgroundView = noDataLabel
        collectionTable.backgroundColor = .systemBackground
        collectionTable.separatorStyle = .none
    }
    
    // MARK: - TableViewDelegate Methods
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if(collectionItems.count == 0){
            noData(message: "You haven't added any collections yet!")
        } else {
            tableView.backgroundView = nil
        }
        return collectionItems.count
    }
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    // Set header appearance
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    // Populate table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell using a cell identifier
        guard let cell = collectionTable.dequeueReusableCell(withIdentifier: K.collectionCellIdentifier, for: indexPath) as? CollectionTableViewCell else { fatalError("The dequeued cell is not an instance of CollectionTableViewCell") }
        
        // Edit cell appearance here
        let item = collectionItems[indexPath.section]
        //let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
        // Gradient colour
//        let colourTheme = UIColor(hexString: K.thirdColour)
//        if let colour = colourTheme!.darken(byPercentage: CGFloat(indexPath.section) / (CGFloat(10))) {
//            cell.backgroundColor = colour as! CGColor
//        }
        
        if(item.recurring){
            cell.repeatBtn.tintColor = UIColor(hexString: K.secondColour)
        } else {
            cell.repeatBtn.tintColor = .clear
        }
        cell.contentView.layer.cornerRadius = 15
        cell.layer.cornerRadius = 15
        cell.collectionTitle.text = item.title
        cell.collectionDate.text = K.weekdaysFromDateComponent[item.collectionDate]
        //cell.accessoryType = accessory
        
        return cell
    }
    
    // Toggle complete or not
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(collectionTable .isEditing) {
            // Delete old entry (will get re added upon return segue)
//            // Remove from collection items
//            collectionItems.remove(at: indexPath.section)
//            // Update user defaults
//            UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)
//            // Remove from table
//            tableView.deleteSections([indexPath.section], with: .top)
            // Perform all UI updates on the main queue.
            DispatchQueue.main.async(execute: {
                // Segue to edit view
                self.performSegue(withIdentifier: K.editCollectionSegue, sender: indexPath.section)
            })
            
        } else {
            // Toggle collection
            let item = collectionItems[indexPath.section]
            item.done = !item.done
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Swipe left to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section < collectionItems.count {
            // Remove from collection items
            collectionItems.remove(at: indexPath.section)
            // Update user defaults
            UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)
            // Remove pending notification
            if let cell = collectionTable.cellForRow(at: indexPath) as? CollectionTableViewCell {
                manager.deleteNotification(id: cell.collectionTitle.text!)
            }
            // Remove from table
            tableView.deleteSections([indexPath.section], with: .top)
        }
    }
    
    // Editing cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editVC = segue.destination as? NewCollectionViewController, segue.identifier == K.editCollectionSegue {
            if let index = sender as? Int {
                editVC.editCollection = true
                editVC.collectionToEdit = collectionItems[index]
                editVC.collectionIndexPathSection = index
            }
        }
    }
    
}

