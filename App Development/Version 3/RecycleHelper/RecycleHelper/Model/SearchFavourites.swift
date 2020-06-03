//
//  SearchFavourites.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 03/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UIKit

class SearchFavourites: ObservableObject {
    
    // Items the user has favourited
    private var items: Set<String>
    
    // User Defaults key
    private let saveKey = "SearchFavourites"
    
    init() {
        // Load saved data
        
        // If no data, use an empty array
        self.items = []
    }
    
    // Check if item is already saved
    func contains(_ item: String) -> Bool {
        return items.contains(item)
    }
    
    // Adds the item
    func add(_ item: String) {
        objectWillChange.send()
        items.insert(item)
        save()
    }

    // Removes the item
    func remove(_ item: String) {
        objectWillChange.send()
        items.remove(item)
        save()
    }

    func save() {
        // write out our data
    }

}


