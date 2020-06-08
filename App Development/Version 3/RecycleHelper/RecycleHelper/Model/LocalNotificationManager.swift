//
//  LocalNotificationManager.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct Notification {
    var id: String
    var title: String
    var datetime: DateComponents
    var recurring: Bool
    var repeatFrequency: String
}

class LocalNotificationManager {
    
    var notifications = [Notification]()
    
    // Check what notifications have been scheduled
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }
    
    // Notification authorisation
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    // Check permission status
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .denied:
                self.requestAuthorization()
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                self.requestAuthorization()
            }
        }
    }
    
    // Schedule notifications
    private func scheduleNotifications() {
        for notification in notifications {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.body     = "Your bin collection is coming up."
            content.sound    = .default
            
            var notificationDate: DateComponents
            var request: UNNotificationRequest
            
            if(notification.recurring){
                let weekday = notification.datetime.weekday
                let hour = notification.datetime.hour
                let minute = notification.datetime.minute
                notificationDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: hour, minute: minute, weekday: weekday)
                
                if(notification.repeatFrequency == "Weekly") {
                    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: notification.recurring)
                    request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                    performScheduling(request: request, id: notification.id, frequency: notification.repeatFrequency)
                } else if (notification.repeatFrequency == "Fortnightly") {
                    let twoWeeks = 1190507.790425003
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: twoWeeks, repeats: notification.recurring)
                    request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                    performScheduling(request: request, id: notification.id, frequency: notification.repeatFrequency)
                }
            } else {
                notificationDate = notification.datetime
                let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: notification.recurring)
                request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                performScheduling(request: request, id: notification.id, frequency: notification.repeatFrequency)
            }

           
        }
    }
    
    func performScheduling(request: UNNotificationRequest, id: String, frequency: String) {
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
            print("Notification scheduled with frequency = \(frequency) and ID = \(id)")
        }
    }
    
    
    // Delete a scheduled notification
    func deleteNotification(id: String) {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
        
            switch settings.authorizationStatus {
            case .denied:
                self.requestAuthorization()
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                
                print("Notification deleted! --- ID = \(id)")
            default:
                break // Do nothing
            }
            
        }
        
    }
}


// Workflow for scheduling notifications:
//  1.  Check if the user has given permission to schedule/handle local notifications
//  2.  If no permission has been asked before, ask the user for permission
//  3.  If permission has been given, schedule the local notifications
//  4.  If permission has been asked before, but the user declined, do nothing
