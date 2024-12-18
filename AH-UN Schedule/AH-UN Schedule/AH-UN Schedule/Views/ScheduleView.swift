//
//  CalendarView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 15/03/2024.
//

import SwiftUI

struct ScheduleView: View {
    @State var date: Date = Date.now
    
    @State var schedule: [Date: [Shift]]?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack {
                        WeekController(date: $date)
                        .padding(.bottom)
                        
                        DayController(date: $date, schedule: $schedule)
                    }
                    .padding()
                    .frame(width: geometry.size.width)
                    .background(Color(uiColor: UIColor.systemGray6))
                    
                    ScheduleList(date: $date, schedule: $schedule)
                }
            }
        }
    }
}

#Preview {
    ScheduleView()
}
