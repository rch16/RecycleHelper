//
//  SearchViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 18/05/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import CoreLocation

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    // Attach UI
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewOption: UIBarButtonItem!
    @IBAction func didChangeViewOption(_ sender: UIBarButtonItem) {
        showFavourites.toggle()
        favouritesView()
    }
    
    // Search Bar
    var searchActive: Bool = false
    var filteredData: [String] = []
    var noDataLabel: UILabel!
    
    // Table Data
    var ref: DatabaseReference = Database.database().reference()
    var tableData: [String: [String: Any]]!
    var tableList: [String]!
    var favouriteItems: [String]!
    var showFavourites: Bool!
    var favouritesList: [String]!
    var currentList: [String]!

    override func viewWillAppear(_ animated: Bool) {
        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        // Search status
        searchActive = false
        // Get user defaults
        getUserDefaults()
        // Check favourites data
        favouritesView()
        // Check whether to display favourites or all items
        checkView()
        // Reload data to reflect changes
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get user defaults
        getUserDefaults()
        // Load the data
        loadItemData()
        // Check favourites data
        favouritesView()
        // Load data from database
        loadDatabaseData()
        // Check whether to display favourites or all
        checkView()
        // Setup delegates
        searchBar.delegate = self
        // UI Appearance
        self.tableView.scrollsToTop = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.visibleViewController!.title = "Search"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.tableView.keyboardDismissMode = .onDrag
        self.searchBar.showsCancelButton = false
        // Reload data to reflect changes
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Loading Data Methods
    
    
    private func loadItemData() {
        // Read from the plist file into the dictionary.
        if let path = Bundle.main.path(forResource: K.searchData, ofType: "plist") {
            tableData = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            tableList = Array(tableData.keys)
            tableList = tableList.sorted()
        }
    }
    
    func loadDatabaseData() {
        
        var searchCriteria: String

        
        guard let location = UserDefaults.standard.object(forKey: K.userLocation) as? String else {
            return
        }
        
        if location == " " {
            searchCriteria = "Default"
        } else {
            // If app has detected location
            searchCriteria = location
        }

        self.ref.child("Data").observe(.value, with: { (snapshot) in
            if searchCriteria != nil, searchCriteria != "" {
                if snapshot.hasChild(searchCriteria) {
                    // If data exists for location
                    if let dict = snapshot.childSnapshot(forPath: searchCriteria).value as? [String: [String: Any]] {
                        self.tableData = dict
                    }
                } else {
                    if let dict = snapshot.childSnapshot(forPath: "Default").value as? [String: [String: Any]] {
                        self.tableData = dict
                        
                    }
                }
            } else {
                if let dict = snapshot.childSnapshot(forPath: "Default").value as? [String: [String: Any]] {
                    self.tableData = dict
                    
                }
            }
            self.tableList = Array(self.tableData.keys)
            self.tableList = self.tableList.sorted()
            self.filteredData = self.tableList
            self.favouritesView()
            self.tableView.reloadData()
        })
   
    }
    
    func getUserDefaults() {
        favouriteItems = (UserDefaults.standard.object(forKey: K.saveItemKey) as? [String])!
        showFavourites = (UserDefaults.standard.object(forKey: K.showFavourites) as? Bool)!
        favouritesList = favouriteItems
    }
    
    func checkIfFavourite(item: String) -> Bool {
        if let _ = favouriteItems.firstIndex(of: item) {
            return true
        } else {
            return false
        }
    }
    
    func checkView() {
        var message: String
        
        if showFavourites {
            if searchActive {
                currentList = filteredData
                message = "No results found."
            } else {
                currentList = favouritesList
                message = "You haven't saved any favourites yet!"
            }
        } else if searchActive {
            currentList = filteredData
            message = "No results found."
        } else {
            currentList = tableList
            message = "No results found."
        }
            
        if(currentList.count == 0){
            noData(message: message)
        } else {
            tableView.separatorStyle  = .singleLine
            tableView.backgroundView = nil
        }
    }
    
    func noData(message: String) {
        noDataLabel = UILabel(frame: CGRect(x: 30, y: 300, width: self.tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = message
        noDataLabel.textColor = .secondaryLabel
        noDataLabel.textAlignment = .center
        noDataLabel.contentMode = .top
        tableView.backgroundView = noDataLabel
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
    }
    
    func favouritesView() {
        if (showFavourites) {
            // Change user default to true
            UserDefaults.standard.set(showFavourites, forKey: K.showFavourites)
            // Change button title
            viewOption.title = "View All"
            // Update current list
            currentList = favouritesList
            self.tableView.reloadData()
        } else {
            // Change user default to false
            UserDefaults.standard.set(showFavourites, forKey: K.showFavourites)
            // Change button title
            viewOption.title = "Favourites"
            // Update current list
            if searchActive {
                currentList = filteredData
            } else {
                currentList = tableList
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Search Bar Functionality
    
    func checkSearchText(searchBar: UISearchBar) {
        if let searchedText = searchBar.searchTextField.text {
            if searchedText.isEmpty {
                searchActive = false
            } else {
                searchActive = true
            }
        } else {
            searchActive = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        checkSearchText(searchBar: searchBar)
        checkView()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        checkSearchText(searchBar: searchBar)
        checkView()
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        checkSearchText(searchBar: searchBar)
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var searchList: [String]
        
        if showFavourites {
            searchList = favouritesList
        } else {
            searchList = tableList
        }
        
        if searchText.isEmpty {
            searchActive = false
            currentList = searchList
            tableView.reloadData()
        } else {
            searchActive = true
            filteredData = searchList.filter { (item: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
            currentList = filteredData
            self.tableView.reloadData()
            
            if(currentList.count == 0){
               noData(message: "No results found.")
            } else {
               tableView.separatorStyle  = .singleLine
               tableView.backgroundView = nil
            }
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkView()
        return currentList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as? ItemTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        // Fetches the appropriate item for the data source layout.
        let item = currentList[indexPath.row]

        if (checkIfFavourite(item: item)) {
            //cell.isFavourite.setImage(UIImage(systemName: "star.fill"), for: .normal)
            cell.isFavourite.tintColor = UIColor(hexString: K.secondColour)
        } else {
            cell.isFavourite.tintColor = .clear
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
                if showFavourites {
                    itemVC.fromFavourites = true
                } else {
                    itemVC.fromFavourites = false
                }
                if searchActive {
                    let itemID = filteredData[itemIndex]
                    itemVC.itemID = itemID
                    itemVC.itemInfo = tableData[itemID]
                } else {
                    let itemID = currentList[itemIndex]
                    itemVC.itemID = itemID
                    itemVC.itemInfo = tableData[itemID]
                }
                
                
            }
        }
    }

}

