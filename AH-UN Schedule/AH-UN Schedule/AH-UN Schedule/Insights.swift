////
////  Insights.swift
////  AH-UN Schedule
////
////  Created by ZoutigeWolf on 17/03/2024.
////
//
//import Foundation
//
//typealias ScheduleManifest = [Int: [Int: [Date: Shift]]]
//
//class Insights {
//    private static func loadData() -> ScheduleManifest {
//        var manifest: ScheduleManifest = [:]
//        
//        for schedule in Storage.loadAll() {
//            if !manifest.contains(where: { $0.key == schedule.year }) {
//                manifest[schedule.year] = [:]
//            }
//            
//            for (i, people) in schedule.days {
//                guard let p = people.first(where: { $0.name == Configuration.user?.name }) else {
//                    continue
//                }
//                
//                guard let date = DateUtils.parseDate(year: schedule.year, weekNumber: schedule.week, dayOfWeekIndex: i) else {
//                    continue
//                }
//                
//                let month = DateUtils.getDateComponent(date, .month);
//                
//                if !manifest[schedule.year]!.contains(where: { $0.key == month }) {
//                    manifest[schedule.year]![month] = [:]
//                }
//                
//                manifest[schedule.year]![month]![date] = p
//            }
//        }
//        
//        return manifest
//    }
//    
//    private static func loadMonth(_ date: Date) -> [ScheduledPerson] {
//        let year = DateUtils.getDateComponent(date, .year)
//        let month = DateUtils.getDateComponent(date, .month)
//        
//        let data = loadData()
//        
//        guard let yData = data[year],
//              let mData = yData[month] else {
//            return []
//        }
//        
//        
//        return Array(mData.values)
//    }
//    
//    static func daysWorkedInMonth(date: Date) -> Int {
//        return loadMonth(date).count
//    }
//    
//    static func timeWorkedInMonth(date: Date) -> Time {
//        var total: Time = Time(hour: 0, minutes: 0)
//        
//        for p in loadMonth(date) {
//            let diff = p.startTime.timeBetween(p.endTime ?? Time(hour: 22, minutes: 00))
//            total = total.add(diff)
//        }
//        
//        return total
//    }
//    
//    static func earningsInMonth(date: Date) -> Double {
//        return timeWorkedInMonth(date: date).totalTime() * Configuration.wage
//    }
//    
//    static func averageShiftLength(date: Date) -> [Int: Double] {
//        var data: [Int: [Double]] = [
//            0: [],
//            1: [],
//            2: [],
//            3: [],
//            4: [],
//            5: [],
//            6: [],
//        ]
//        
//        for p in loadMonth(date) {
//            guard let d = p.date else {
//                continue
//            }
//            
//            let day = DateUtils.getDayIndex(d)
//            
//            data[day]!.append(p.startTime.timeBetween(p.endTime ?? Time(hour: 22, minutes: 00)).totalTime())
//        }
//        
//        var output: [Int: Double] = [:]
//        
//        for (day, hours) in data {
//            output[day] = avg(hours)
//        }
//        
//        return output
//    }
//    
//    static func avg(_ data: [Double]) -> Double {
//        return Double(data.reduce(0, +)) / Double(data.count)
//    }
//}
