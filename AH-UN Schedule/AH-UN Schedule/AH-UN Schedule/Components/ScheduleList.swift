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
    @State var isLoading: Bool = false
    @State var showFailedAlert: Bool = false
    
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
                ForEach(groupByTimes(schedule![date]!).sorted(by: { $0.key < $1.key }), id: \.0) { time, shifts in
                    Section(header: Text(time)) {
                        ForEach(shifts, id: \.id) { s in
                            if (AuthManager.shared.user!.username == s.user.username || AuthManager.shared.user!.admin) {
                                NavigationLink(destination: EditShiftView(shift: s)) {
                                    ScheduleItem(shift: s)
                                }
                            } else {
                                ScheduleItem(shift: s)
                            }
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            .onAppear {
                reload()
            }
            .onChange(of: date) {
                reload()
            }
        } else {
            VStack {
                Spacer()
                
                if !isLoading {
                    Text("No schedule for this week yet.")
                        .padding(.bottom, 4)
                    
                    if AuthManager.shared.user!.admin {
                        PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .not(.livePhotos)])) {
                            Text("Add schedule")
                        }
                    }
                } else {
                    ProgressView() {
                        Text("Processing schedule...")
                    }
                }
                
                Spacer()
            }
            .alert(isPresented: $showFailedAlert) {
                Alert(title: Text("Failed to upload schedule"))
            }
            .onAppear {
                reload()
            }
            .onChange(of: date) {
                reload()
            }
            .onChange(of: selectedPhoto) {
                isLoading = true
                
                Task {
                    let image = try? await selectedPhoto?.loadTransferable(type: Data.self)
                    
                    selectedPhoto = nil
                    
                    guard let image = image else {
                        return
                    }
                    
                    ScheduleManager.parse(image) { res in
                        if res {
                            DispatchQueue.main.async {
                                isLoading = false;
                                
                                reload()
                            }
                        } else {
                            DispatchQueue.main.async {
                                showFailedAlert = true
                                isLoading = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reload() {
        ScheduleManager.getWeekSchedule(year: DateUtils.getDateComponent(date, .year), week: DateUtils.getDateComponent(date, .weekOfYear)) { schedule in
            DispatchQueue.main.async {
                self.schedule = schedule
                print(schedule)
            }
        }
    }
}
