//
//  SettingsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 15/03/2024.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    @AppStorage("enableCalendar") private var enableCalendar: Bool = false
    @AppStorage("selectedCalendar") private var selectedCalendar: String?
    @AppStorage("eventTitle") private var eventTitle: String = "Work"
    @AppStorage("dishesNotation") private var dishesNotation: String = "Dishes"
    @AppStorage("meatNotation") private var meatNotation: String = "Meat"
    @AppStorage("salary") private var salary: Double = 0
    
    @State private var token: String = ""
    
    private let calendarManager = CalendarManager()
    
    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    var body: some View {
        List {
            NavigationLink("Account", destination: EditUserView(user: AuthManager.shared.user!))
            
            Section(header: Text("Calendar"), footer: Text("When calendar synchronization is enabled your schedule will automatically be added to the selected calendar when a new schedule is uploaded. Your name must be set for this feature to work.")) {
                Toggle(isOn: $enableCalendar) {
                    Text("Sync calendar")
                }
                
                Picker("Calendar", selection: self.$selectedCalendar) {
                    Text("None").tag(nil as String?)
                    ForEach(calendarManager.calendars, id: \.calendarIdentifier) { c in
                        Text(c.title).tag(c.calendarIdentifier as String?)
                    }
                }
                .disabled(!enableCalendar)
            }
            
            Section(header: Text("Event Title"), footer: Text("The title of the calendar event.")) {
                TextField("Title", text: self.$eventTitle)
            }
            
            Section(header: Text("Position Notations"), footer: Text("How your position is displayed in your calendar.")) {
                Picker("Dishes", selection: $dishesNotation) {
                    Text("Dishes").tag("Dishes")
                    Text("Afwas").tag("Afwas")
                }
                .pickerStyle(.segmented)
                
                Picker("Meat", selection: $meatNotation) {
                    Text("Meat").tag("Meat")
                    Text("Vlees").tag("Vlees")
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Wage"), footer: Text("Your wage is used to calculate your estimated salary.")) {
                Stepper(value: $salary, in: 1...100, step: 0.5) {
                    HStack(alignment: .bottom) {
                        Text(salary, format: .currency(code: "EUR"))
                        Text("/ hour")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 10))
                            .padding(.bottom, 3)
                    }
                }
                .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
