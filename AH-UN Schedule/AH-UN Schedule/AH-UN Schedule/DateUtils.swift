//
//  DateUtils.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import Foundation

final class DateUtils {
    static func editDate(_ date: Date, months: Int = 0, weeks: Int = 0, days: Int = 0) -> Date {
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.weekOfYear = weeks
        components.month = months
        components.day = days
        
        if let newDate = calendar.date(byAdding: components, to: date) {
            return newDate
        } else {
            return date
        }
    }
    
    static func editDate(_ date: Date, hour: Int, minutes: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        dateComponents.hour = hour
        dateComponents.minute = minutes
        dateComponents.second = 0

        return calendar.date(from: dateComponents)
    }
    
    static func getMonthName(_ date: Date) -> String {
        let calendar = Calendar.current
        let monthIndex = calendar.component(.month, from: date)
        return calendar.monthSymbols[monthIndex - 1]
    }
    
    static func getDayName(_ date: Date) -> String {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        return calendar.shortWeekdaySymbols[weekdayIndex - 1]
    }
    
    static func getFullDayName(_ date: Date) -> String {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        return calendar.weekdaySymbols[weekdayIndex - 1]
    }
    
    static func getDayName(_ idx: Int) -> String {
        let calendar = Calendar.current
        return calendar.shortWeekdaySymbols[(idx + 1) % 7]
    }
    
    static func getDayIndex(_ date: Date) -> Int {
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: date)
        
        return (weekDay + 5) % 7
    }
    
    static func getDatesForWeek(_ date: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        var startDate = Date()
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .weekOfYear, start: &startDate, interval: &interval, for: date)

        var datesInWeek: [Date] = []
        
        for dayOffset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                datesInWeek.append(day)
            }
        }
        
        return datesInWeek
    }
    
    static func getDateComponent(_ date: Date, _ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: date)
    }
    
    static func firstDayOfWeek(year: Int, week: Int) -> Date? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        var components = DateComponents()
        components.year = year
        components.weekOfYear = week
        components.weekday = 2
        
        return calendar.date(from: components)
    }
    
    static func parseDate(year: Int, weekNumber: Int, dayOfWeekIndex: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.weekOfYear = weekNumber
        dateComponents.weekday = (dayOfWeekIndex + 2) % 7

        return Calendar.current.date(from: dateComponents)
    }
    
    static func parseDate(hour: Int, minutes: Int) -> Date? {
        return Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: Date.now)
    }
    
    static func numberOfDays(inMonth date: Date) -> Int {
        let calendar = Calendar.current
        
        if let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        } else {
            return 0
        }
    }
    
    static func parseHours(_ hours: Double) -> (Int, Int) {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        
        return (h, m)
    }
}

extension Date {
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    func isSameDate(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: otherDate)
        return components1 == components2
    }
    
    func hourAndMinute() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func toCurrentTimeZone() -> Date {
        let timeZone = TimeZone.current
        let secondsFromGMT = TimeInterval(timeZone.secondsFromGMT(for: self))
        return Date(timeInterval: secondsFromGMT, since: self)
    }
    
    func roundedToNearestQuarterHour() -> Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        let remainder = minutes % 15
        let adjustment = remainder < 8 ? -remainder : (15 - remainder)
        return calendar.date(byAdding: .minute, value: adjustment, to: self) ?? self
    }
    
    static func fromString(_ dateString: String, as format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: dateString)
    }
    
    func toString(as format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
