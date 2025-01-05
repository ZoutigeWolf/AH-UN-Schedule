//
//  EditShiftView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 20/03/2024.
//

import SwiftUI

struct EditShiftView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let shift: Shift
    
    @State var start: Date
    @State var end: Date
    @State var canceled: Bool
    @State var position: Position? = nil
    
    private static let calendarManager: CalendarManager = CalendarManager()
    
    init(shift: Shift) {
        self.shift = shift
        
        _start = State(initialValue: shift.start)
        _end = State(initialValue: shift.end ?? DateUtils.parseDate(hour: 22, minutes: 0)!)
        _canceled = State(initialValue: shift.canceled)
        _position = State(initialValue: shift.position)
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Start time", selection: $start, displayedComponents: [.hourAndMinute])
                DatePicker("End time", selection: $end, displayedComponents: [.hourAndMinute])
            }
            
            Section {
                Toggle(isOn: $canceled) {
                    Text("Canceled")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("\(shift.user.name) \($start.wrappedValue.toString(as: "HH:mm"))")
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("\(DateUtils.getFullDayName(shift.start)), \(DateUtils.getMonthName(shift.start)) \(DateUtils.getDateComponent(shift.start, .day))")
                    
                    Text("\(shift.user.name)")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                }
            }
        }
    }
    
    func save() {
        ScheduleManager.editShift(id: shift.id, start: start, end: end, canceled: canceled) { shift in
            
        }
    }
}
