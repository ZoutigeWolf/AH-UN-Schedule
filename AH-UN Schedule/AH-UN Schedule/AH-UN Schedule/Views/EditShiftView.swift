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
    @State var position: Position? = nil
    
    private static let calendarManager: CalendarManager = CalendarManager()
    
    init(shift: Shift) {
        self.shift = shift
        
        _start = State(initialValue: shift.start)
        _end = State(initialValue: shift.end ?? DateUtils.parseDate(hour: 22, minutes: 0)!)
        _position = State(initialValue: shift.position)
    }
    
    var body: some View {
        List {
            Section(header: Text("Name")) {
                Text(shift.user.name)
            }
            
            Section(header: Text("Position")) {
                Picker("Position", selection: self.$position) {
                    Text("None").tag(nil as Position?)
                    ForEach(Position.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p as Position?)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                DatePicker("Start time", selection: $start, displayedComponents: [.hourAndMinute])
                DatePicker("End time", selection: $end, displayedComponents: [.hourAndMinute])
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
//            ToolbarItem(placement: .principal) {
//                VStack {
//                    Text("\(DateUtils.getFullDayName(shift.date!)), \(DateUtils.getMonthName(shift.date!)) \(DateUtils.getDateComponent(shift.date!, .day))")
//                    
//                    if shift.endTime == nil {
//                        Text(shift.startTime.toString())
//                            .foregroundStyle(.secondary)
//                            .font(.system(size: 12))
//                    } else {
//                        Text("\(shift.startTime.toString()) - \(shift.endTime!.toString())")
//                            .foregroundStyle(.secondary)
//                            .font(.system(size: 12))
//                    }
//                }
//            }
//            
//            ToolbarItem(placement: .confirmationAction) {
//                Button {
//                    save()
//                    presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Text("Done")
//                }
//            }
        }
    }
    
    func save() {
        ScheduleManager.editShift(id: shift.id, start: shift.start, end: shift.end) { shift in
            
        }
    }
}
