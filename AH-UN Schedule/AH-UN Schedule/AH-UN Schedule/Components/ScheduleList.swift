//
//  ScheduleList.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import SwiftUI
import PhotosUI

struct ScheduleList: View {
    @Binding var date: Date
    
    @Binding var schedule: [Date: [Shift]]?
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var showUploadAlert: Bool = false
    
    func groupByTimes(_ shifts: [Shift]) -> [String: [Shift]] {
        var groups: [String: [Shift]] = [:]
        
        for s in shifts {
            let start = s.start.hourAndMinute()
            if !groups.keys.contains(start) {
                groups[start] = []
            }
            
            groups[start]?.append(s)
        }
        
        return groups
    }
    
    var body: some View {
        if (schedule?[date]?.count ?? 0 > 0) {
            List {
                
                let groups = groupByTimes(schedule![date]!).sorted(by: { $0.key < $1.key })
                
                ForEach(groups, id: \.0) { time, shifts in
                    Section {
                        ForEach(shifts, id: \.id) { s in
                            if (AuthManager.shared.user!.username == s.user!.username || AuthManager.shared.user!.admin) {
                                NavigationLink(destination: EditShiftView(shift: s)) {
                                    ScheduleItem(shift: s)
                                }
                            } else {
                                ScheduleItem(shift: s)
                            }
                        }
                    } header: {
                        Text(time)
                    }
                }
                
//                Button {
//                    print(date)
//                } label: {
//                    Text(Calendar.current.date(byAdding: .day, value: 1, to: date)! >= Date.now ? "I work this day" : "I worked this day")
//                }
            }
        } else {
            VStack {
                Spacer()
                
                Text("No schedule for this week yet.")
                    .padding(.bottom, 4)
                
                if AuthManager.shared.user!.admin {
                    PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .not(.livePhotos)])) {
                        Text("Add schedule")
                    }
                }
                
                Spacer()
            }
            .alert(isPresented: $showUploadAlert) {
                Alert(title: Text("Schedule uploaded successfully, you'll be notified when it has been processed."))
            }
            .onChange(of: selectedPhoto) { _ in
                Task {
                    let image = try? await selectedPhoto?.loadTransferable(type: Data.self)
                    
                    selectedPhoto = nil
                    
                    guard let image = image else {
                        return
                    }
                    
                    ScheduleManager.parse(image) { res in
                        DispatchQueue.main.async {
                            showUploadAlert = true
                        }
                    }
                }
            }
        }
    }
}
