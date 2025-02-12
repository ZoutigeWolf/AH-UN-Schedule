//
//  CalendarView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 15/03/2024.
//

import SwiftUI

struct ScheduleView: View {
    @State var date: Date = DateUtils.getDatesForWeek(Date.now)[DateUtils.getDayIndex(Date.now)]
    
    @State var schedule: [Date: [Shift]]?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    VStack {
                        VStack {
                            WeekController(date: $date)
                            .padding(.bottom)
                            
                            DayController(date: $date, schedule: $schedule)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 4)
                        .frame(width: geometry.size.width)
                        .background(Color(uiColor: UIColor.systemGray6))
                        
                        ScheduleList(date: $date, schedule: $schedule)
                    }
                    
//                    Button {
//                        print("Test")
//                    } label: {
//                        Image(systemName: "plus")
//                            .foregroundStyle(.white)
//                            .font(.system(size: 20))
//                            .padding(8)
//                            .background(.primary)
//                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 6, height: 6)))
//                            .padding(.bottom, 12)
//                            .padding(.trailing, 12)
//                    }
                }
            }
        }
        .onAppear {
            reload()
        }
        .onChange(of: date) { _ in
            reload()
        }
    }
    
    func reload() {
        ScheduleManager.getWeekSchedule(year: DateUtils.getDateComponent(date, .year), week: DateUtils.getDateComponent(date, .weekOfYear)) { schedule in
            DispatchQueue.main.async {
                self.schedule = schedule
            }
        }
    }
}

#Preview {
    ScheduleView()
}
