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
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func cancelDaySelection(segue: UIStoryboardSegue) {}
    @IBAction func dayWasSelected(segue: UIStoryboardSegue) {
        // get data
        if let sourceVC = segue.source as? WeekdayViewController {
            dateJustChanged = true
            
            // Get Info
            let weekday = sourceVC.selectedWeekday
            //let date = Calendar.current.
            let indexPath = IndexPath(row: 0, section: 1)
            let cell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
            
            // Update Data
            collectionDay = weekday!
            collectionToEdit?.collectionDate = collectionDay
            newCollection?.collectionDate = collectionDay
            cell.updateCollection(text: cell.label.text!, day: collectionDay)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    // Date Picker
    var collections = [CollectionItem]()
    var inputTexts: [String] = ["Collection date", "Reminder date"]
    var inputDates: [Date] = []
    var collectionDay: Int = Calendar.current.dateComponents([.weekday], from: Date.init()).weekday!
    var datePickerIndexPath: IndexPath?
    
    // Text Field
    var textChanged: ((String) -> Void)?
    
    // Collection data
    var newCollection: CollectionItem?
    var editCollection: Bool = false
    var collectionToEdit: CollectionItem?
    var collectionIndexPathSection: Int?
    var dateJustChanged: Bool = false
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
        let currentDate = Date.init()
        let currentDateComponents = Calendar.current.dateComponents([.weekday], from: currentDate)
        newCollection = CollectionItem(title: "", collectionDate: currentDateComponents.weekday!, reminderDate: currentDate, recurring: false)
        // alter navigation header and add button depending on purpose
        addBtn.possibleTitles = ["Add", "Done"]
        if editCollection {
            navBar.topItem!.title = "Edit Collection"
            addBtn.title = "Done"
            // Fill view with selected collection data
            populateData()
            
        } else {
            navBar.topItem!.title = "New Collection"
            addBtn.title = "Add"
        }
    }

    func addInitialValues() {
        inputDates = Array(repeating: Date(), count: inputTexts.count)
    }
    
    func populateData() {
        if !dateJustChanged {
            collectionDay = collectionToEdit?.collectionDate as! Int
        } else {
            dateJustChanged = false
        }
        inputDates[1] = collectionToEdit?.reminderDate as! Date
        newCollection?.collectionDate = collectionToEdit?.collectionDate as! Int
        newCollection?.reminderDate = collectionToEdit?.reminderDate as! Date
        newCollection?.recurring = collectionToEdit?.recurring as! Bool
        newCollection?.title = collectionToEdit?.title as! String
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
                self.performSegue(withIdentifier: K.selectWeekdaySegue, sender: indexPath)
            } else {
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
            }
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 1 {
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
        if indexPath.section == 0 {
            guard let titleCell = tableView.dequeueReusableCell(withIdentifier: K.titleCellIdentifier, for: indexPath as IndexPath) as? TitleTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TitleTableViewCell.")}
           // titleCell.delegate = self
            if editCollection {
                titleCell.configure(text: collectionToEdit?.title, placeholder: "")
            } else {
                titleCell.configure(text: "", placeholder: "Collection Title")
            }
            titleCell.collectionTitle.delegate = self
            return titleCell
        } else if indexPath.section == 2 {
            guard let switchCell = tableView.dequeueReusableCell(withIdentifier: K.repeatsCellIdentifier, for: indexPath as IndexPath) as? SetsRepeatTableViewCell  else {
                 fatalError("The dequeued cell is not an instance of SetsRepeatTableViewCell.")}
            if editCollection {
                switchCell.configure(value: collectionToEdit?.recurring)
            } else {
                switchCell.configure(value: false)
            }
            switchCell.delegate = self
            return switchCell
        } else {
            if indexPath.row == 0 {
                // Collection day selection
                guard let collectionCell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath as IndexPath) as? EventTableViewCell  else {
                    fatalError("The dequeued cell is not an instance of EventTableViewCell.")}
                collectionCell.updateCollection(text: inputTexts[indexPath.row], day: collectionDay)
                let accessory: UITableViewCell.AccessoryType = .disclosureIndicator
                collectionCell.accessoryType = accessory
                return collectionCell
            } else if datePickerIndexPath == indexPath {
                // Select day and time of reminder
                guard let datePickerCell = tableView.dequeueReusableCell(withIdentifier: K.datePickerCellIdentifier, for: indexPath as IndexPath) as? DatePickerTableViewCell  else {
                    fatalError("The dequeued cell is not an instance of DatePickerTableViewCell.")}
                if(inputTexts[indexPath.row - 1].contains("Collection")) {
                    datePickerCell.datePicker.datePickerMode = .date
                } else {
                    datePickerCell.datePicker.datePickerMode = .dateAndTime
                }
                datePickerCell.updateCell(date: inputDates[indexPath.row - 1], indexPath: indexPath)
                datePickerCell.delegate = self
                return datePickerCell
            } else {
                // Reminder day selection
                guard let reminderCell = tableView.dequeueReusableCell(withIdentifier: K.eventCellIdentifier, for: indexPath as IndexPath) as? EventTableViewCell  else {
                    fatalError("The dequeued cell is not an instance of EventTableViewCell.")}
                reminderCell.updateText(text: inputTexts[indexPath.row], date: inputDates[indexPath.row])
                return reminderCell
            }
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? WeekdayViewController, segue.identifier == K.selectWeekdaySegue {
            if let selectedPath = sender as! IndexPath? {
                let cell = tableView.cellForRow(at: selectedPath) as! EventTableViewCell
                nextVC.currentWeekday = cell.dateLabel.text
            }
        }
    }
    
}

// MARK: - DatePickerDelegate Methods

extension NewCollectionViewController: DatePickerDelegate {
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
        if indexPath.row == 0 {
            // collection date
            newCollection?.collectionDate = collectionDay
        } else {
            // reminder date
            newCollection?.reminderDate = date
        }
        if addBtn.title == "Done" {
            self.addBtn.isEnabled = true
        }
    }
    
}

// MARK: - SwitchDelegate Methods

extension NewCollectionViewController: SwitchDelegate {
    
    func didChangeValue(value: Bool) {
        newCollection?.recurring = value
        if addBtn.title == "Done" {
            self.addBtn.isEnabled = true
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
        guard let text = textField.text
        else { preconditionFailure("Expected a Title") }
        
        if text == "" {
            self.addBtn.isEnabled = false
        } else {
            self.addBtn.isEnabled = true
        }
        
        newCollection?.title = text
    }
}
