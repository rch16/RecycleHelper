//
//  SymbolViewController.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 01/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class SymbolViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Attach UI
    @IBOutlet weak var viewOptions: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func viewOptionChanged(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    // Label data
    var labelData: [String: [String: Any]]!
    var generalData: [String: Any]!
    var generalList: [String]!
    var plasticData: [String: Any]!
    var plasticList: [String] = ["PETE","HDPE","PVC","LDPE","PP","PS","Other"] // to preserve order
    var otherData: [String: Any]!
    var otherList: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show navigation bar
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.title = "Symbols"
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // Assign table data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        // Table appearance
        tableView.separatorColor = .clear
        // Load data to populate table with
        loadSymbolData()
    }

    func loadSymbolData() {
        // Read from the plist file into the dictionary
        if let path = Bundle.main.path(forResource: K.symbolData, ofType: "plist") {
            let url = URL(fileURLWithPath: path)
            labelData = NSDictionary(contentsOf: url) as? [String: [String: Any]]
            // General Labels
            generalData = labelData["General"]
            generalList = Array(generalData.keys)
            // Plastic Labels
            plasticData = labelData["Plastic"]
            // Other Labels
            otherData = labelData["Other"]
            otherList = Array(otherData.keys)
            otherList.sort()
        }
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let currentView = viewOptions.titleForSegment(at: viewOptions.selectedSegmentIndex)
        if currentView == "General" {
            return generalList.count
        } else if currentView == "Plastic" {
            return plasticList.count
        } else {
            return otherList.count
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(K.cellSpacingHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.symbolCellIdentifier, for: indexPath) as? SymbolTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SymbolTableViewCell.")
        }
        
        var item: String
        var data: NSDictionary
        var listNum: Int
        
        // Fetches the appropriate item for the data source layout.
        let currentView = viewOptions.titleForSegment(at: viewOptions.selectedSegmentIndex)
        if currentView == "General" {
            item = generalList[indexPath.section]
            data = (generalData[item] as? NSDictionary)!
            listNum = generalList.count
        } else if currentView == "Plastic" {
            item = plasticList[indexPath.section]
            data = (plasticData[item] as? NSDictionary)!
            listNum = plasticList.count
        } else {
            item = otherList[indexPath.section]
            data = (otherData[item] as? NSDictionary)!
            listNum = otherList.count
        }
        
        let imageName = data["Image"] as? String
        if let picture = UIImage(named: imageName!){
             cell.cellImage.image = picture
         }
        
        // Gradient colour
        let colourTheme = UIColor(hexString: K.thirdColour)
        if let colour = colourTheme!.darken(byPercentage: CGFloat(indexPath.section) / (CGFloat(listNum)*2.5)) {
            cell.backgroundColor = colour
        }
        
        cell.symbolName.text = item
        cell.accessoryView?.tintColor = .darkGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let symbolVC = segue.destination as? SymbolInfoViewController, segue.identifier == K.symbolInfoSegue {
            
            let currentView = viewOptions.titleForSegment(at: viewOptions.selectedSegmentIndex)
            
            if let itemIndex = tableView.indexPathForSelectedRow?.section {
                symbolVC.category = currentView
                if currentView == "General" {
                    symbolVC.symbolID  = generalList[itemIndex]
                } else if currentView == "Plastic" {
                    symbolVC.symbolID  = plasticList[itemIndex]
                } else {
                    symbolVC.symbolID  = otherList[itemIndex]
                }
                
            }
        }
    }

}
