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
    var collectionDate: Int
    var reminderDate: Date
    var done: Bool
    var recurring: Bool
    
    public init(title: String, collectionDate: Int, reminderDate: Date, recurring: Bool) {
        self.title = title
        self.collectionDate = collectionDate
        self.reminderDate = reminderDate
        self.done = false
        self.recurring = recurring
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
            CollectionItem(title: "Test1", collectionDate: 0, reminderDate: someDateTime!, recurring: true),
            CollectionItem(title: "Test2", collectionDate: 0, reminderDate: someDateTime!, recurring: false)
        ]
    }
}
