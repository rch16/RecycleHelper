//
//  LocalNotificationManager.swift
//  RecycleHelper
//
//  Created by Becca Hallam on 05/06/2020.
//  Copyright © 2020 Becca Hallam. All rights reserved.
//

import Foundation
import UserNotifications

struct Notification {
    var id: String
    var title: String
    var datetime: DateComponents
    var recurring: Bool
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
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
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
            
            if(notification.recurring){
                let weekday = notification.datetime.weekday
                let hour = notification.datetime.hour
                let minute = notification.datetime.minute
                notificationDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, hour: hour, minute: minute, weekday: weekday)
            } else {
                notificationDate = notification.datetime
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: notification.recurring)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")

            }
        }
    }
    
    // Delete a scheduled notification
    func deleteNotification(id: String) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        print("Notification deleted! --- ID = \(id)")
    }
}


// Workflow for scheduling notifications:
//  1.  Check if the user has given permission to schedule/handle local notifications
//  2.  If no permission has been asked before, ask the user for permission
//  3.  If permission has been given, schedule the local notifications
//  4.  If permission has been asked before, but the user declined, do nothing
