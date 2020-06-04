//
//  NewCollectionViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class NewCollectionViewController: UITableViewController {
    
    // Attach UI
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    // Date Picker
    var collections = [CollectionItem]()
    var inputTexts: [String] = ["Collection date", "Reminder date"]
    var inputDates: [Date] = []
    var datePickerIndexPath: IndexPath?
    
    // Text Field
    var textChanged: ((String) -> Void)?
    
    // Collection data
    var newCollection: CollectionItem?
    //var collectionTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addInitialValues()
        // Change navigation bar appearance
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Table appearance
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.backgroundColor = .systemGray5
        // Add button initially disabled
        addBtn.isEnabled = false
        // Initialise new collection
        newCollection = CollectionItem(title: "", collectionDate: Date.init(), reminderDate: Date.init())
    }
    
    func setDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm MMMMd")
        return dateFormatter
    }
    
    func addInitialValues() {
        inputDates = Array(repeating: Date(), count: inputTexts.count)
    }
    
    
    // MARK: - Table View Data Source
    
    // Set the spacing between sections
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            tableView.beginUpdates() // because there is more than one action below
            // Three outcomes:
            // 1. no date picker shown (datePickerIndexPath = nil) -> tap a row, and a date picker is shown underneath
            // 2. date picker shown -> tap a different row, date picker is hidden and another shown underneath tapped row.
            //    a. the tapped row is above the shown date picker
            //    b. the tapped row is below the shown date picker
            if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
                   tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                    tableView.deselectRow(at: indexPath, animated: true)
                   self.datePickerIndexPath = nil
               } else {
                   if let datePickerIndexPath = datePickerIndexPath {
                       tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                        tableView.deselectRow(at: indexPath, animated: true)
                   }
                   datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                   tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                   tableView.deselectRow(at: indexPath, animated: true)
               }
               tableView.endUpdates()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if datePickerIndexPath != nil {
            // add a row to show the event picker
            return inputTexts.count + 1
        } else {
            return inputTexts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if datePickerIndexPath == indexPath {
            return DatePickerTableViewCell.cellHeight()
        } else {
            return EventTableViewCell.cellHeight()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        //let dateFormatter = setDateFormatter()
        if indexPath.section == 0 {
            guard let titleCell = tableView.dequeueReusableCell(withIdentifier: K.titleCellIdentifier, for: indexPath as IndexPath) as? TitleTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TitleTableViewCell.")}
           // titleCell.delegate = self
            titleCell.configure(text: "", placeholder: "Collection Title")
            titleCell.collectionTitle.delegate = self
            titleCell.collectionTitle.tag = indexPath.row + 1
            return titleCell
        }
        else if datePickerIndexPath == indexPath {
            guard let datePickerCell = tableView.dequeueReusableCell(withIdentifier: K.datePickerCellIdentifier, for: indexPath as IndexPath) as? DatePickerTableViewCell  else {
                fatalError("The dequeued cell is not an instance of DatePickerTableViewCell.")}
            datePickerCell.updateCell(date: inputDates[indexPath.row - 1], indexPath: indexPath)
            datePickerCell.delegate = self
            return datePickerCell
        } else {
            guard let eventCell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath as IndexPath) as? EventTableViewCell  else {
                fatalError("The dequeued cell is not an instance of EventTableViewCell.")}
            eventCell.updateText(text: inputTexts[indexPath.row], date: inputDates[indexPath.row])
            return eventCell
        }
    
    }
    
}

// MARK: - DatePickerDelegate Methods

extension NewCollectionViewController: DatePickerDelegate {
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        inputDates[indexPath.row] = date
        tableView.reloadRows(at: [indexPath], with: .none)
        if indexPath.row == 0 {
            // collection date
            newCollection?.collectionDate = date
        } else {
            // reminder date
            newCollection?.reminderDate = date
        }
    }
    
}

// MARK: - UITextFieldDelegate Methods

extension NewCollectionViewController: UITextFieldDelegate {
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        textChanged?(textView.text)
        tableView.endUpdates()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //addBtn.isEnabled = true
        return true
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            print("TextField text is nil")
            return
        }
        
        if text == "" {
            self.addBtn.isEnabled = false
        } else {
            self.addBtn.isEnabled = true
        }
        
        newCollection?.title = text
    }
}
