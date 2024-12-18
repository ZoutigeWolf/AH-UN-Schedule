//
//  WeekController.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import SwiftUI

struct WeekController: View {
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Button {
                date = DateUtils.editDate(date, weeks: -1)
            } label: {
                Image(systemName: "arrow.left.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            VStack {
                Text("Week \(DateUtils.getDateComponent(date, .weekOfYear))")
                
                Text("\(String(DateUtils.getMonthName(date))) \(String(DateUtils.getDateComponent(date, .year)))")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            Button {
                date = DateUtils.editDate(date, weeks: 1)
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
            }
        }
    }
}
