//
//  SettingsManager.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 09/01/2025.
//

import Foundation

final class SettingsManager {
    static func getSettings(completion: @escaping (Settings?) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/users/" + AuthManager.shared.user!.username + "/settings", token: AuthManager.shared.token) { (res: Result<Settings?, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let settings):
                completion(settings)
            }
        }
    }
    
    static func editSettings(wage: Double, calendarEventTitle: String, notificationsNewSchedule: Bool, notificationsWorkReminder: Bool, notificationsWorkReminderTime: Double, completion: @escaping (Settings?) -> Void) {
        struct _SettingsData: Codable {
            var wage: Double
            var calendar_event_title: String
            var notifications_new_schedule: Bool
            var notifications_work_reminder: Bool
            var notifications_work_reminder_time: Double
        }
        
        let data = _SettingsData(
            wage: wage,
            calendar_event_title: calendarEventTitle,
            notifications_new_schedule: notificationsNewSchedule,
            notifications_work_reminder: notificationsWorkReminder,
            notifications_work_reminder_time: notificationsWorkReminderTime
        )
        
        Requests.patch(url: AuthManager.serverUrl + "/users/" + AuthManager.shared.user!.username + "/settings", token: AuthManager.shared.token, data: data) { (res: Result<Settings?, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let settings):
                completion(settings)
            }
        }
    }
}
