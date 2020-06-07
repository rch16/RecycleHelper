//
//  SettingsViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 06/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    var userName: String!
    
    // Number of sections
    var sectionNum: Int = 3
    
    // Text Field
    var textChanged: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change navigation bar appearance
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Table appearance
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.backgroundColor = .systemGray5
        // Load data
        loadData()
    
    }
    
    func loadData() {
        guard let personalisation = UserDefaults.standard.object(forKey: K.personalisation) as? String else {
            return
        }
        userName = personalisation
    }

    
    
    // MARK: - Table View Data Source
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
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
        if section == 1 {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // About
                let cell = tableView.dequeueReusableCell(withIdentifier: K.aboutCellIdentifier, for: indexPath as IndexPath)
                return cell
            } else {
                // Edit personalisation
                guard let cell = tableView.dequeueReusableCell(withIdentifier: K.settingsCellIdentifier, for: indexPath as IndexPath) as? SettingsTableViewCell  else {
                    fatalError("The dequeued cell is not an instance of SettingsTableViewCell.")}
                
                cell.nameTextField.delegate = self
                cell.nameTextField.text = userName
                
                return cell
            }
            
        } else if indexPath.section == 1 {
            // Show onboarding
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            
            cell.actionBtn.setTitle(K.onboardingBtnTitle, for: .normal)
            cell.actionBtn.setTitleColor(UIColor(hexString: K.thirdColour), for: .normal)
            cell.delegate = self
            
            return cell
        } else {
            // Clear...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: K.buttonCellIdentifier, for: indexPath as IndexPath) as? ButtonTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ButtonTableViewCell.")}
            
            if indexPath.row == 0 {
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
        }
    }

    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            if indexPath.section == 0, indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                let title: String = "Designed and built by Rebecca Hallam"
                let message: String = "As part of her final year project for an MEng Degree in Electrical and Electronic Engineering at Imperial College London."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
        }
    }
    

}

// MARK: - CellSegueDelegate Methods

extension SettingsViewController: CellSegueDelegate {
    
    func callSegueFromCell(_ sender: Any?) {
        if let buttonTitle = sender as? String {
            if buttonTitle == K.onboardingBtnTitle {
                // Show onboarding
                self.performSegue(withIdentifier: K.showOnboardingSegue, sender: nil)
            } else {
                // Delete actions
                
                // Show action sheet to make sure
                let optionMenu = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
                    
                let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    if buttonTitle == K.clearCollectionsBtnTitle {
                        // Haptic feedback
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.success)
                        // Delete bin collections
                        UserDefaults.standard.set([CollectionItem](), forKey: K.binCollections)
                        // Show completion
                        self.showCompletionAlert(message: "Bin collections cleared successfully.")

                    } else if buttonTitle == K.clearFavouritesBtnTitle {
                        // Haptic feedback
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.success)
                        // Delete search favourites
                        UserDefaults.standard.set(false, forKey: K.showFavourites)
                        UserDefaults.standard.set([], forKey: K.saveItemKey)
                        // Show completion
                        self.showCompletionAlert(message: "Search favourites cleared successfully.")
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

                optionMenu.addAction(yesAction)
                optionMenu.addAction(cancelAction)

                self.present(optionMenu, animated: true, completion: nil)
            }
            
            

        }
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
        userName = textField.text
        textField.resignFirstResponder()
        return true
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userName = textField.text
        UserDefaults.standard.set(userName, forKey: K.personalisation)
    }
}
