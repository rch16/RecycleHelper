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
        return CGFloat(30)
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.settingsCellIdentifier, for: indexPath as IndexPath) as? SettingsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SettingsTableViewCell.")}
        cell.nameTextField.delegate = self
        cell.nameTextField.text = userName
        
        return cell
    
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
