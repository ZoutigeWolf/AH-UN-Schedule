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
    
    init(shift: Shift) {
        self.shift = shift
        
        _start = State(initialValue: shift.start)
        _end = State(initialValue: shift.end ?? DateUtils.editDate(shift.start, hour: 22, minutes: 0)!)
        _canceled = State(initialValue: shift.canceled)
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Start time", selection: $start, displayedComponents: [.hourAndMinute])
                    .onChange(of: start) { _ in
                        start = start.roundedToNearestQuarterHour()
                    }
                    .disabled(canceled)
                
                DatePicker("End time", selection: $end, displayedComponents: [.hourAndMinute])
                    .onChange(of: end) { _ in
                        end = end.roundedToNearestQuarterHour()
                    }
                    .disabled(canceled)
            }
            
            Section {
                Toggle(isOn: $canceled) {
                    Text("Canceled")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("\(DateUtils.getFullDayName(shift.start)), \(DateUtils.getMonthName(shift.start)) \(DateUtils.getDateComponent(shift.start, .day))")
                    
                    Text("\(shift.user!.name)")
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
