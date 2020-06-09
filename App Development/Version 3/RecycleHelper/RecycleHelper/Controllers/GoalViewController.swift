//
//  WeekdayViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 06/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class GoalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Attach UI
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var dataTable: UITableView!
    @IBAction func cancelWasPressed(_ sender: Any) {
    }
    
    var selectedData: Int!
    var cancelPressed: Bool = true
    var currentData: String!
    var data: [String] = K.goalArray
    var returnData: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelPressed = false
        // Assign table data source and delegate
        dataTable.dataSource = self
        dataTable.delegate = self
        // Table appearance
        dataTable.backgroundColor = .systemGray5
        dataTable.tableFooterView = UIView() // prevent extra separators
        self.navBar.topItem?.title = "Select Goal"

    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dataTable.dequeueReusableCell(withIdentifier: K.weekdayCellIdentifier, for: indexPath) as? WeekdayTableViewCell  else {
           fatalError("The dequeued cell is not an instance of WeekdayTableViewCell.")
        }
        
        
        cell.dataLabel.text = data[indexPath.row]

        
        if cell.dataLabel.text == currentData {
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
        if segue.identifier == K.goalSegue {
            let selectedPath = dataTable.indexPathForSelectedRow
            returnData = selectedPath!.row
        }
    }
    
}
