//
//  WeekdayViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 06/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class WeekdayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Attach UI
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var dataTable: UITableView!
    @IBAction func cancelWasPressed(_ sender: Any) {
    }
    
    var selectedData: Int!
    var frequency: String!
    var frequencyArray: [String]!
    var cancelPressed: Bool = true
    var currentData: String!
    var selectFrequency: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelPressed = false
        // Assign table data source and delegate
        dataTable.dataSource = self
        dataTable.delegate = self
        // Table appearance
        dataTable.backgroundColor = .systemGray5
        dataTable.tableFooterView = UIView() // prevent extra separators
        if selectFrequency {
            self.navBar.topItem?.title = "Reminder Frequency"
        } else {
            self.navBar.topItem?.title = "Collection Day"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectFrequency {
            return frequencyArray.count
        } else {
            return K.weekdayStrings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dataTable.dequeueReusableCell(withIdentifier: K.weekdayCellIdentifier, for: indexPath) as? WeekdayTableViewCell  else {
           fatalError("The dequeued cell is not an instance of WeekdayTableViewCell.")
        }
        
        var data: String
        
        if selectFrequency {
            data = frequencyArray[indexPath.row]
            cell.dataLabel.text = data
        } else {
            data = K.weekdayStrings[indexPath.row]
            cell.dataLabel.text = data
            
        }
        
        if data == currentData {
            cell.checkmarkLabel.isHidden = false
        } else {
            cell.checkmarkLabel.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.addDaySegue {
            let selectedPath = dataTable.indexPathForSelectedRow
            if selectFrequency {
                frequency = frequencyArray[selectedPath!.row]
            } else {
                selectedData = K.weekdayValues[selectedPath!.row]
            }
        }
    }
    
}
