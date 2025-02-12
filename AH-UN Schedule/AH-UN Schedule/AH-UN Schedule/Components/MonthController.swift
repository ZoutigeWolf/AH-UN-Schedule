//
//  MonthController.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 17/03/2024.
//

import SwiftUI

struct MonthController: View {
    @Binding var date: Date
    
    var body: some View {
        HStack {
            Button {
                date = DateUtils.editDate(date, months: -1)
            } label: {
                Image(systemName: "arrow.left")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            VStack {
                Text(DateUtils.getMonthName(date))
                
                Text(String(DateUtils.getDateComponent(date, .year)))
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            Button {
                date = DateUtils.editDate(date, months: 1)
            } label: {
                Image(systemName: "arrow.right")
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
            }
        }
    }
}
