//
//  SettingsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 15/03/2024.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    @State var settings: Settings?
    
    var body: some View {
        NavigationStack {
            if settings != nil {
                List {
                    Section {
                        NavigationLink(destination: AccountSettingsView(settings: Binding($settings)!, onSave: save)) {
                            Text("Account")
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: CalendarSettingsView(settings: Binding($settings)!, onSave: save)) {
                            Text("Calendar")
                        }
                        
                        NavigationLink(destination: NotificationsSettingsView(settings: Binding($settings)!, onSave: save)) {
                            Text("Notifications")
                        }
                    }
                }
                .navigationTitle("Settings")
                .refreshable {
                    reload()
                }
            } else {
                ProgressView()
                    .navigationTitle("Settings")
            }
        }
        .onAppear() {
            reload()
        }
    }
    
    func reload() {
        SettingsManager.getSettings() { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func save() {
        guard let settings = settings else {
            return
        }
        
        SettingsManager.editSettings(
            wage: settings.wage,
            calendarEventTitle: settings.calendarEventTitle,
            notificationsNewSchedule: settings.notificationsNewSchedule,
            notificationsWorkReminder: settings.notificationsWorkReminder,
            notificationsWorkReminderTime: settings.notificationsWorkReminderTime
        ) { _ in }
    }
}
