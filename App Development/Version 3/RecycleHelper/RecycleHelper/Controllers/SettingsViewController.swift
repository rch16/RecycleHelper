//
//  SettingsViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 06/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class SettingsViewController: UITableViewController, SwitchDelegate {
    
    @IBAction func cancelGoalSelection(segue: UIStoryboardSegue) {}
    @IBAction func goalWasSelected(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? GoalViewController {
            let indexPath = IndexPath(row: 0, section: recyclingInfo)
            targetJustChanged = true
            let goal = sourceVC.returnData
            recyclingTarget = K.goalIntArray[goal ?? 6]
            UserDefaults.standard.set(recyclingTarget, forKey: K.recycleTarget)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
    }
    
    var ref: DatabaseReference = Database.database().reference()
    var userName: String!
    var lastUpdated: String!
    var animated: Bool = true
    var recyclingTarget: Int = 50
    var targetJustChanged: Bool = false
    
    // Number of sections
    var sectionNum: Int = 7
    
    // Number of rows in section
    var rowInSection = [2,2,1,1,1,3,1]
    // 1. App information - about, and last updated data
    // 2. User personalisation - name and animation
    // 3. Recycling target
    // 4. Show onboarding
    // 5. Change privacy settings
    // 6. Clear specific data
    // 7. Reset app
    
    let appInfo = 0
    let userInfo = 1
    let recyclingInfo = 2
    let showOnboarding = 3
    let changePrivacySettings = 4
    let clearData = 5
    let clearApp = 6
    
    // Text Field
    var textChanged: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load data
        loadData()
        // Load Database data
        loadDatabaseData()
        // Change navigation bar appearance
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Table appearance
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.backgroundColor = .systemGray5
    }
    
    func loadData() {
        guard let personalisation = UserDefaults.standard.object(forKey: K.personalisation) as? String else {
            return
        }
        userName = personalisation
        
        let updated = (UserDefaults.standard.object(forKey: K.lastUpdated) as? String)!
        lastUpdated = updated
        
        if let target = UserDefaults.standard.object(forKey: K.recycleTarget) as? Int {
            recyclingTarget = target
        }
        
    }

    func loadDatabaseData() {
        self.ref.child("Last Updated").observe(.value, with: { (snapshot) in
            if let updatedDate = snapshot.value as? String {
                UserDefaults.standard.set(updatedDate, forKey: K.lastUpdated)
                self.lastUpdated = updatedDate
            }
       })
    }
    
    
    // MARK: - Table View Data Source
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == sectionNum - 1 {
            return CGFloat(30)
        } else {
            return CGFloat(0)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNum
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowInSection[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        if indexPath.section == appInfo {
            if indexPath.row == 0 {
                // About
                let cell = tableView.dequeueReusableCell(withIdentifier: K.aboutCellIdentifier, for: indexPath as IndexPath)
                return cell
            } else {
                // Information last updated on
                let cell = tableView.dequeueReusableCell(withIdentifier: K.updatedInfoCellIdentifier, for: indexPath as IndexPath)
                
                cell.detailTextLabel?.text = lastUpdated
                
                return cell
            }
            
        } else if indexPath.section == userInfo {
            if indexPath.row == 0 {
                // Edit personalisation
               guard let cell = tableView.dequeueReusableCell(withIdentifier: K.settingsCellIdentifier, for: indexPath as IndexPath) as? SettingsTableViewCell  else {
                   fatalError("The dequeued cell is not an instance of SettingsTableViewCell.")}
               
                cell.nameTextField.delegate = self
                cell.nameTextField.text = userName
                cell.nameTextField.tag = 0
               
               return cell
            } else {
                // Animated typing on/off
                guard let switchCell = tableView.dequeueReusableCell(withIdentifier: K.repeatsCellIdentifier, for: indexPath as IndexPath) as? SetsRepeatTableViewCell  else {
                     fatalError("The dequeued cell is not an instance of SetsRepeatTableViewCell.")}
                
                if let animate = UserDefaults.standard.object(forKey: K.animatedTyping) as? Bool  {
                    animated = animate
                }
                
                switchCell.configure(value: animated)
                switchCell.delegate = self
                return switchCell
            }

        } else if indexPath.section == showOnboarding {
            // Show onboarding
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            
            cell.actionBtn.setTitle(K.onboardingBtnTitle, for: .normal)
            cell.actionBtn.setTitleColor(UIColor(hexString: K.thirdColour), for: .normal)
            cell.delegate = self
            
            return cell
        } else if indexPath.section == changePrivacySettings {
            // Change privacy settings
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            
            cell.actionBtn.setTitle(K.changePrivacyBtnTitle, for: .normal)
            cell.actionBtn.setTitleColor(UIColor(hexString: K.thirdColour), for: .normal)
            cell.delegate = self
            
            return cell
            
        } else if indexPath.section == clearData {
            // Clear...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            
            if indexPath.row == 0 {
                // ... Recycle progress
                cell.actionBtn.setTitle(K.clearProgressBtnTitle, for: .normal)
                cell.actionBtn.setTitleColor(.red, for: .normal)
            } else if indexPath.row == 1 {
                // ... Collections
                cell.actionBtn.setTitle(K.clearCollectionsBtnTitle, for: .normal)
                cell.actionBtn.setTitleColor(.red, for: .normal)
            } else {
                // ... Search favourites
                cell.actionBtn.setTitle(K.clearFavouritesBtnTitle, for: .normal)
                cell.actionBtn.setTitleColor(.red, for: .normal)
            }
            
            cell.delegate = self
            return cell
        } else if indexPath.section == recyclingInfo {
            guard let goalCell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath as IndexPath) as? EventTableViewCell  else {
                fatalError("The dequeued cell is not an instance of EventTableViewCell.")}
            
            goalCell.updateGoal(text: "Recycling Goal", goal: recyclingTarget)
            
            let accessory: UITableViewCell.AccessoryType = .disclosureIndicator
            goalCell.accessoryType = accessory
            
            return goalCell
        } else {
            // Clearing app
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            cell.actionBtn.setTitle(K.resetAppBtnTitle, for: .normal)
            cell.actionBtn.setTitleColor(.red, for: .normal)
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == recyclingInfo {
            // Select goal
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: K.selectGoalSegue, sender: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            if indexPath.section == appInfo, indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                let title: String = "Designed and built by Rebecca Hallam"
                let message: String = "As part of her final year project for an MEng Degree in Electrical and Electronic Engineering at Imperial College London."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            } else if indexPath.section == recyclingInfo {
                // Select recycling target
                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: K.selectWeekdaySegue, sender: indexPath)
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedPath = sender as? IndexPath? {
            if let nextVC = segue.destination as? GoalViewController, segue.identifier == K.selectGoalSegue, selectedPath!.section == recyclingInfo {
                let cell = tableView.cellForRow(at: selectedPath!) as! EventTableViewCell

                nextVC.currentData = cell.valueLabel.text
            }
        }
    }
        
    // MARK: - SwitchDelegate Methods
    
    func didChangeValue(value: Bool) {
       
        animated = value
        UserDefaults.standard.set(animated, forKey: K.animatedTyping)
    }
    

}

// MARK: - CellActionDelegate Methods

extension SettingsViewController: CellActionDelegate {
    
    func callSegueFromCell(_ sender: Any?) {
        if let buttonTitle = sender as? String {
            if buttonTitle == K.onboardingBtnTitle {
                // Show onboarding
                self.performSegue(withIdentifier: K.showOnboardingSegue, sender: nil)
            } else if buttonTitle == K.changePrivacyBtnTitle {
                let optionMenu = UIAlertController(title: nil, message: "You are about to be redirected to your phone's settings", preferredStyle: .actionSheet)
                let yesAction = UIAlertAction(title: "OK", style: .destructive, handler: { action in
                    // Haptic feedback
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                    // Open settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

                optionMenu.addAction(yesAction)
                optionMenu.addAction(cancelAction)

                self.present(optionMenu, animated: true, completion: nil)
            } else {
                // Delete actions
                
                // Show action sheet to make sure
                let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
                    
                let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    // Haptic feedback
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                    if buttonTitle == K.clearCollectionsBtnTitle {
                        // Delete bin collections
                        UserDefaults.standard.set([CollectionItem](), forKey: K.binCollections)
                        // Show completion
                        self.showCompletionAlert(message: "Bin collections cleared successfully.")
                    } else if buttonTitle == K.clearFavouritesBtnTitle {
                        // Delete search favourites
                        UserDefaults.standard.set(false, forKey: K.showFavourites)
                        UserDefaults.standard.set([], forKey: K.saveItemKey)
                        // Show completion
                        self.showCompletionAlert(message: "Search favourites cleared successfully.")
                    } else if buttonTitle == K.clearProgressBtnTitle {
                       // Clear recycle count
                       UserDefaults.standard.set(0, forKey: K.recycleCount)
                       // Show completion
                       self.showCompletionAlert(message: "Recycling progress reset successfully.")
                    } else if buttonTitle == K.resetAppBtnTitle {
                        // Clear all user defaults
                        UserDefaults.standard.set([], forKey: K.saveItemKey)
                        UserDefaults.standard.set(false, forKey: K.showFavourites)
                        UserDefaults.standard.set([CollectionItem](), forKey: K.binCollections)
                        UserDefaults.standard.set(false, forKey: K.hasPersonalised)
                        UserDefaults.standard.set("", forKey: K.personalisation)
                        UserDefaults.standard.set("", forKey: K.lastUpdated)
                        UserDefaults.standard.set("", forKey: K.userLocation)
                        UserDefaults.standard.set(true, forKey: K.animatedTyping)
                        UserDefaults.standard.set(0, forKey: K.recycleCount)
                        UserDefaults.standard.set(50, forKey: K.recycleCount)
                        UserDefaults.standard.set(false, forKey: K.shownInstructions)
                        // Show completion
                        self.showCompletionAlertAndSegue(message: "App reset successfully.")
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

                optionMenu.addAction(yesAction)
                optionMenu.addAction(cancelAction)

                self.present(optionMenu, animated: true, completion: nil)
            }
            
            

        }
    }
    
    // Show completion and then segue
    func showCompletionAlertAndSegue(message: String) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            // Segue to onboarding
            self.performSegue(withIdentifier: K.showOnboardingSegue, sender: nil)
        }))
        self.present(alert, animated: true)
    }
    
    // Show completion
    func showCompletionAlert(message: String) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}



// MARK: - UITextFieldDelegate Methods

extension SettingsViewController: UITextFieldDelegate {
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        textChanged?(textView.text)
        tableView.endUpdates()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            userName = textField.text
        }
        textField.resignFirstResponder()
        return true
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            userName = textField.text
            UserDefaults.standard.set(userName, forKey: K.personalisation)
        }
    }
}
