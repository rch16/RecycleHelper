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
    var filtered:[String] = []
    
    // Table Data
    var tableData: [String: [String: Any]]!
    var tableList: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup delegates
        searchBar.delegate = self
        // Make navigation bar opaque
        self.navigationController?.navigationBar.isTranslucent = false
        // Load the data
        loadItemData()
        
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

        filtered = tableList.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return filtered.count
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
            item = filtered[indexPath.row]
        } else {
            item = tableList[indexPath.row]
        }
        
        cell.nameLabel.text = item
        
        return cell
    }
    
    //MARK: Private Methods
    
    private func loadItemData() {
        // Read from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: K.searchData, ofType: "plist") {
            tableData = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            tableList = Array(tableData.keys)
            tableList = tableList.sorted()
        }
    }

}
