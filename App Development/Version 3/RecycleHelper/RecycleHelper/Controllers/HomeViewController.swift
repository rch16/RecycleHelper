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
import FirebaseDatabase
import CoreLocation

class HomeViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var ref: DatabaseReference = Database.database().reference()
    
    @IBAction func unwindAddingCollection(segue: UIStoryboardSegue) {}
    @IBAction func finishAddingCollection(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? NewCollectionViewController {
            if sourceVC.editCollection {
                // Overwrite edited collection
                editCollection = sourceVC.newCollection
                updateCollection(section: sourceVC.collectionIndexPathSection!, title: editCollection!.title, collectionDate: editCollection!.collectionDate, reminderDate: editCollection!.reminderDate, recurring: editCollection!.recurring, repeatFrequency: editCollection!.repeatFrequency)
            } else {
                // Add new collection
                newCollection = sourceVC.newCollection
                addNewCollection(title: newCollection!.title, collectionDate: newCollection!.collectionDate, reminderDate: newCollection!.reminderDate, recurring: newCollection!.recurring, repeatFrequency: newCollection!.repeatFrequency)
            }
        }
    }
    @IBAction func finishedEditingSettings(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SettingsViewController {
            
            // Check animation
            animated = sourceVC.animated
            let text = "Welcome, " + sourceVC.userName
            if animated {
                userName.text = text
                nonAnimatedUserName.text = " "
            } else {
                userName.text = " "
                nonAnimatedUserName.text = text
            }
            
            // Check recycle count
            getRecycledItemCount()
            progressView.setProgress(progress, animated: true)
        }
    }
    
    // Attach UI
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var itemsRecycledLabel: UILabel!
    @IBOutlet weak var factTable: UITableView!
    @IBOutlet weak var nonAnimatedUserName: UILabel!
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

    // Location specific information (for search view)
    var placemark: CLPlacemark?
    var city: String?
    var postCode: String?
    var locationManager = CLLocationManager()
    private var locationResult: LocationSetupResult = .success
    private enum LocationSetupResult {
        case success
        case notAuthorized
    }
    
    // Fun facts
    var factsArray: [String] = []
    var currentFact: String = ""
    
    // Personalisation
    var animated: Bool = true
    
    // Recycling usage stats
    var recycledItemCount: Int = 0
    var target: Double = 50.0
    var progress: Double = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Populate fact
        chooseRandomFact()
        // Get recycled item count
        getRecycledItemCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Update progess
        progressView.setProgress(progress, animated: true)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup location
        locationManager.delegate = self
        // Check for Location Services
        checkLocationServices()
        // Check personalisation
        checkPersonalisation()
        // Get user defaults
        getUserDefaults()
        // Load database data
        loadDatabaseData()
        // Navigation bar appearance
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // Assign tables data source and delegate
        collectionTable.dataSource = self
        collectionTable.delegate = self
        factTable.dataSource = self
        factTable.delegate = self
        // Alter tables appearance
        collectionTable.separatorStyle = .none
        factTable.separatorStyle = .none
        // Populate fun fact
        self.chooseRandomFact()
    }
    
    // MARK: - Obtain Data
    
    func getRecycledItemCount() {
        if let count = UserDefaults.standard.object(forKey: K.recycleCount) as? Int {
            recycledItemCount = count
        }
        if let goal = UserDefaults.standard.object(forKey: K.recycleTarget) as? Int {
            target = Double(goal)
        }
        
        if recycledItemCount != 0 {
            if Double(recycledItemCount) >= target {
                // goal reached!
                let alert = UIAlertController(title: "Congratulations!", message: "You have reached your goal! Let's aim for the next \(Int(target)) items.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true)

                // Update user defaults
                recycledItemCount = 0
                UserDefaults.standard.set(recycledItemCount, forKey: K.recycleCount)
            }
            
            progress = Double(recycledItemCount)/target
            
        } else {
            progress = Double(0)
        }
        
        let fraction: String = String(recycledItemCount) + "/" + String(Int(target))
        itemsRecycledLabel.text = fraction + " items recycled"
        
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
                    let text = "Welcome, " + personalisation
                    if self.animated {
                        self.userName.text = text
                        self.nonAnimatedUserName.text = " "
                    } else {
                        self.userName.text = " "
                        self.nonAnimatedUserName.text = text
                    }
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
            
            if let animate = UserDefaults.standard.object(forKey: K.animatedTyping) as? Bool {
                animated = animate
            }
            
            let text = "Welcome, " + personalisation
            if animated {
                userName.text = text
                nonAnimatedUserName.text = " "

            } else {
                userName.text = " "
                nonAnimatedUserName.text = text
            }

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
        
        if let animate = UserDefaults.standard.object(forKey: K.animatedTyping) as? Bool {
            animated = animate
        }
     }
    
    func loadDatabaseData() {
        self.ref.child("Facts").observe(.value, with: { (snapshot) in
            
            if snapshot.hasChild("Recycling Facts") {
                if let factsDict = snapshot.childSnapshot(forPath: "Recycling Facts").value as? [String: String] {
                    for fact in factsDict {
                        self.factsArray.append(fact.value)
                    }
                }
                self.chooseRandomFact()
            }
            
        })
            
    }
    
    func chooseRandomFact() {
        if factsArray != [] {
            let range = factsArray.count
            let randomIndex = Int.random(in: 0..<range)
            let fact = factsArray[randomIndex]
            currentFact = fact
            factTable.reloadData()
        }
    }
    
    // Date format
    func setDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        return dateFormatter
    }
    
    // Add new collection
    func addNewCollection(title: String, collectionDate: Int, reminderDate: Date, recurring: Bool, repeatFrequency: String) {
        // The index of the new item will be the current item count
        let newIndex = collectionItems.count

        // Create new item and add it to the collections list
        collectionItems.append(CollectionItem(title: title, collectionDate: collectionDate, reminderDate: reminderDate, recurring: recurring, repeatFrequency: repeatFrequency))
        
        // Update user defaults
        UserDefaults.standard.set(try? PropertyListEncoder().encode(collectionItems), forKey: K.binCollections)

        // Tell the table view a new row has been created
        self.collectionTable.insertSections([newIndex], with: .top)

        // Schedule notification
        let notificationTitle = "Collection Reminder: " + title
        let notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        manager.notifications.append(Notification(id: title, title: notificationTitle, datetime: notificationDateComponents, recurring: recurring, repeatFrequency: repeatFrequency))
        checkNotificationAuthorisation()
        manager.schedule()
    }
    
    func checkNotificationAuthorisation() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
               
               if !granted {
                   DispatchQueue.main.async {
                   let changePrivacySetting = "RecycleHelper doesn't have permission to provide push notifications, please change privacy settings"
                   let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to push notifications")
                   let alertController = UIAlertController(title: "RecycleHelper", message: message, preferredStyle: .alert)
                   
                   alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                   
                   alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                   }))
                   
                    self.present(alertController, animated: true, completion: nil)
               }
            }
        }
    }
    
    // Edit current colleciton
    func updateCollection(section: Int, title: String, collectionDate: Int, reminderDate: Date, recurring: Bool, repeatFrequency: String) {
        let indexPath = IndexPath(row: 0, section: section)
        
        // Update list
        let item = CollectionItem(title: title, collectionDate: collectionDate, reminderDate: reminderDate, recurring: recurring, repeatFrequency: repeatFrequency)
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
        manager.notifications.append(Notification(id: title, title: notificationTitle, datetime: notificationDateComponents, recurring: recurring, repeatFrequency: repeatFrequency))
        checkNotificationAuthorisation()
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
    
    
    // MARK: - Location Access
    
    func authoriseLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
            checkLocationServices()
        }
    }
    
    func checkLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .authorized, .restricted, .authorizedAlways, .authorizedWhenInUse:
            locationManager.startMonitoringSignificantLocationChanges()
            lookUpCurrentLocation()
            
        case .notDetermined:
            authoriseLocation()
        case .denied:
            DispatchQueue.main.async {
                let changePrivacySetting = "RecycleHelper doesn't have permission to access location, please change privacy settings"
                let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to location services")
                let alertController = UIAlertController(title: "RecycleHelper", message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                        style: .cancel,
                                                        handler: nil))
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                        style: .`default`,
                                                        handler: { _ in
                                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                      options: [:],
                                                                                      completionHandler: nil)
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
        @unknown default:
            checkLocationServices()
        }
        
    }
    
    func lookUpCurrentLocation() {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    self.placemark = placemarks?[0]
                    self.city = self.placemark?.locality
                    self.postCode = self.placemark?.postalCode
                    self.postCode = String(self.postCode!.split(separator: " ")[0]) // Take first half only
                    let userLocation: String = self.city! + ", " + self.postCode!
                    UserDefaults.standard.set(userLocation, forKey: K.userLocation)
                }
                else {
                 // An error occurred during geocoding.
                    print(error)
                }
            })
        }
        else {
            // No location was available.
            print("no location")
        }
    }
    
    
    // MARK: - TableViewDelegate Methods
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == collectionTable {
            if(collectionItems.count == 0){
                noData(message: "You haven't added any collections yet!")
            } else {
                tableView.backgroundView = nil
            }
            return collectionItems.count
        } else {
            return 1
        }
        
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
        if tableView == collectionTable {
            // Dequeue reusable cell using a cell identifier
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.collectionCellIdentifier, for: indexPath) as? CollectionTableViewCell else { fatalError("The dequeued cell is not an instance of CollectionTableViewCell") }
            
            // Edit cell appearance
            let item = collectionItems[indexPath.section]

            
            if(item.recurring){
                cell.repeatBtn.tintColor = UIColor(hexString: K.secondColour)
            } else {
                cell.repeatBtn.tintColor = .clear
            }
            cell.contentView.layer.cornerRadius = 15
            cell.layer.cornerRadius = 15
            cell.collectionTitle.text = item.title
            cell.collectionDate.text = K.weekdaysFromDateComponent[item.collectionDate]
            
            return cell
        } else {
            // Dequeue reusable cell using a cell identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: K.factCellIdentifier, for: indexPath)
            
            cell.textLabel?.text = currentFact
            cell.contentView.layer.cornerRadius = 15
            cell.layer.cornerRadius = 15
            cell.backgroundColor = UIColor(hexString: K.thirdColour)
            
            return cell
        }
    }
    
    // Toggle complete or not
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == collectionTable {
            if(collectionTable .isEditing) {
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
    }
    
    // Swipe left to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == collectionTable {
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
    }
    
    // Editing cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == collectionTable {
            return true
        } else {
            return false
        }
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


// MARK: CLLocationManagerDelegate Methods

extension HomeViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

}

