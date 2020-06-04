//
//  CollectionItem.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 04/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation

class CollectionItem: Codable {
    var title: String
    var collectionDate: Date
    var reminderDate: Date
    var done: Bool
    var recurring: Bool
    
    public init(title: String, collectionDate: Date, reminderDate: Date) {
        self.title = title
        self.collectionDate = collectionDate
        self.reminderDate = reminderDate
        self.done = false
        self.recurring = false
    }
}

extension CollectionItem {
    public class func getMockData() -> [CollectionItem] {
        var dateComponents = DateComponents()
        let userCalendar = Calendar.current
        
        dateComponents.year = 2020
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.timeZone = TimeZone(abbreviation: "BST")
        dateComponents.hour = 9
        dateComponents.minute = 00
        
        let someDateTime = userCalendar.date(from: dateComponents)
        
        return [
            CollectionItem(title: "Test1", collectionDate: someDateTime!, reminderDate: someDateTime!),
            CollectionItem(title: "Test2", collectionDate: someDateTime!, reminderDate: someDateTime!)
        ]
    }
}
