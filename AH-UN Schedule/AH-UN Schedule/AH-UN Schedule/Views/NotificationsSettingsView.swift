//
//  NotificationsSettingsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 07/01/2025.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @Binding var settings: Settings
    let onSave: () -> Void
    
    @State var scheduleAlert: Bool
    @State var workAlert: Bool
    @State var workAlertTime: Double
    
    init(settings: Binding<Settings>, onSave: @escaping () -> Void) {
        self._settings = settings
        self.onSave = onSave
        
        _scheduleAlert = State(initialValue: settings.wrappedValue.notificationsNewSchedule)
        _workAlert = State(initialValue: settings.wrappedValue.notificationsWorkReminder)
        _workAlertTime = State(initialValue: settings.wrappedValue.notificationsWorkReminderTime)
    }
    
    var body: some View {
        List {
            Section(footer: Text("Get notified when a new schedule is uploaded.")) {
                Toggle("New Schedule Alerts", isOn: $scheduleAlert)
                    .onChange(of: scheduleAlert) { newAlert in
                        settings.notificationsNewSchedule = newAlert
                    }
            }
            
            Section(footer: Text("Get notified some time before your shift starts")) {
                Toggle("Shift Reminders", isOn: $workAlert)
                    .onChange(of: workAlert) { newAlert in
                        settings.notificationsWorkReminder = newAlert
                    }
                
                Picker(selection: $workAlertTime) {
                    Text("15m before").tag(0.25)
                    Text("30m before").tag(0.5)
                    Text("1h before").tag(1.0)
                    Text("2h before").tag(2.0)
                    Text("3h before").tag(3.0)
                    Text("4h before").tag(4.0)
                    Text("5h before").tag(5.0)
                    Text("6h before").tag(6.0)
                } label: {
                    Text("Alert Time")
                }
                .disabled(!workAlert)
                .onChange(of: workAlertTime) { newTime in
                    settings.notificationsWorkReminderTime = newTime
                }
            }
        }
        .navigationTitle(Text("Notifications"))
        .onDisappear() {
            onSave()
        }
    }
}
