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
    @IBOutlet weak var weekdayTable: UITableView!
    @IBAction func cancelWasPressed(_ sender: Any) {
    }
    
    var selectedWeekday: Int!
    var cancelPressed: Bool = true
    var currentWeekday: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelPressed = false
        // Assign table data source and delegate
        weekdayTable.dataSource = self
        weekdayTable.delegate = self
        // Table appearance
        weekdayTable.backgroundColor = .systemGray5
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = weekdayTable.dequeueReusableCell(withIdentifier: K.weekdayCellIdentifier, for: indexPath) as? WeekdayTableViewCell  else {
           fatalError("The dequeued cell is not an instance of WeekdayTableViewCell.")
        }
        
        cell.weekdayLabel.text = K.weekdayStrings[indexPath.row]
        let weekday = K.weekdayStrings[indexPath.row]
        
        if weekday == currentWeekday {
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
            let selectedPath = weekdayTable.indexPathForSelectedRow
            selectedWeekday = K.weekdayValues[selectedPath!.row]
        }
    }
    
}
