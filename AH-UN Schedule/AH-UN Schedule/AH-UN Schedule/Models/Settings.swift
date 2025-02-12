//
//  Settings.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import Foundation

struct Settings: Codable {
    var username: String
    var wage: Double
    var calendarEventTitle: String
    var notificationsNewSchedule: Bool
    var notificationsWorkReminder: Bool
    var notificationsWorkReminderTime: Double
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.username = try container.decode(String.self, forKey: .username)
        self.wage = try container.decode(Double.self, forKey: .wage)
        self.calendarEventTitle = try container.decode(String.self, forKey: .calendarEventTitle)
        self.notificationsNewSchedule = try container.decode(Bool.self, forKey: .notificationsNewSchedule)
        self.notificationsWorkReminder = try container.decode(Bool.self, forKey: .notificationsWorkReminder)
        self.notificationsWorkReminderTime = try container.decode(Double.self, forKey: .notificationsWorkReminderTime)
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case wage = "wage"
        case notificationsNewSchedule = "notifications_new_schedule"
        case calendarEventTitle = "calendar_event_title"
        case notificationsWorkReminder = "notifications_work_reminder"
        case notificationsWorkReminderTime = "notifications_work_reminder_time"
    }
}
