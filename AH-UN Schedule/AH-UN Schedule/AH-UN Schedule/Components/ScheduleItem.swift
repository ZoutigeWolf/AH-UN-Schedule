//
//  ScheduleItem.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import SwiftUI

let positionColors: [String: UIColor] = [
    "Meat": .systemRed,
    "Dishes": .systemBlue
]


struct ScheduleItem: View {
    let shift: Shift
    
    var body: some View {
        HStack {
            HStack(spacing: 2) {
                if AuthManager.shared.user!.username == shift.user.username {
                    Text(shift.user.name)
                        .foregroundStyle(.primary)
                        .bold()
                } else {
                    Text(shift.user.name)
                        .foregroundStyle(.primary)
                }
                
//                if let user = shift.user, user.isFulltime {
//                    Text("F")
//                        .foregroundStyle(.secondary)
//                        .font(.system(size: 10))
//                        .baselineOffset(10)
//                }
            }
            
            if shift.position != .None {
                Text(shift.position.rawValue)
                    .font(.system(size: 12))
                    .padding(4)
                    .background(Color(uiColor: positionColors[shift.position.rawValue] ?? .systemGray))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            if shift.end != nil {
                Text(shift.end!.hourAndMinute())
                    .foregroundStyle(.secondary)
            }
        }
    }
}
