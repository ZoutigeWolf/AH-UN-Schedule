//
//  DayController.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import SwiftUI

struct DayController: View {
    @Binding var date: Date
    @Binding var schedule: [Date: [Shift]]?
    
    var body: some View {
        HStack {
            ForEach(Array(DateUtils.getDatesForWeek(date).enumerated()), id: \.offset) { i, d in
                Button {
                    date = d
                } label: {
                    VStack {
                        if let shift = schedule?[d]?.first(where: { $0.user!.username == AuthManager.shared.user?.username }) {
                            Text(shift.start.hourAndMinute())
                                .foregroundStyle(shift.canceled ? .secondary : .primary)
                                .strikethrough(shift.canceled)
                                .tint(.primary)
                                .font(.system(size: 9))
                                .padding(.bottom, 4)
                        } else {
                            Text("")
                                .font(.system(size: 10))
                                .padding(.bottom, 4)
                        }
                        
                        Text(DateUtils.getDayName(d).uppercased())
                            .foregroundStyle(.secondary)
                            .tint(.secondary)
                            .font(.system(size: 10))
                        
                        Text("\(DateUtils.getDateComponent(d, .day))")
                            .foregroundStyle(.primary)
                            .tint(d.isToday() ? Color.red : Color.primary)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .frame(width: 32, height: 2)
                            .foregroundColor(Color(uiColor: d.isSameDate(date) ? .systemGray : .clear))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
