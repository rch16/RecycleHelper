//
//  SearchViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 18/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    // Search Bar
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false
    var filteredData: [String] = []
    var noDataLabel: UILabel!
    
    // Table Data
    var tableData: [String: [String: Any]]!
    var tableList: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegates
        searchBar.delegate = self
        // Hide navigation bar
        self.navigationController?.isNavigationBarHidden = true
        // Dismiss keyboard on drag
        self.tableView.keyboardDismissMode = .onDrag
        // No cancel button
        self.searchBar.showsCancelButton = false
        // Load the data
        loadItemData()
        filteredData = tableList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Search Bar Functionality
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filteredData = searchText.isEmpty ? tableList : tableList.filter { (item: String) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            if(filteredData.count == 0){
                print("here")
                noDataLabel = UILabel(frame: CGRect(x: 30, y: 300, width: self.tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text          = "No results found."
                noDataLabel.textAlignment = .center
                noDataLabel.contentMode = .top
                tableView.backgroundView  = noDataLabel
                tableView.backgroundColor = UIColor.white
                tableView.separatorStyle  = .none
            } else {
                tableView.separatorStyle  = .singleLine
                tableView.backgroundView = nil
            }
            return filteredData.count
        }
        return tableList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as? ItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        // Fetches the appropriate item for the data source layout.
        var item: String
        
        if(searchActive) {
            item = filteredData[indexPath.row]
        } else {
            item = tableList[indexPath.row]
        }
        
        cell.nameLabel.text = item
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let itemVC = segue.destination as? ItemViewController, segue.identifier == K.searchItemViewSegue {
            if let itemIndex = tableView.indexPathForSelectedRow?.row {
                if(searchActive) {
                    itemVC.itemID = filteredData[itemIndex]
                } else {
                    itemVC.itemID = tableList[itemIndex]
                }
            }
        }
    }
    // MARK: - Private Methods
    
    private func loadItemData() {
        // Read from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: K.searchData, ofType: "plist") {
            tableData = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            tableList = Array(tableData.keys)
            tableList = tableList.sorted()
        }
    }

}
