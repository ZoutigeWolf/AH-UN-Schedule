//
//  ScheduleManager.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import Foundation
import SwiftUI

final class ScheduleManager{
    private static let calendarManager: CalendarManager = CalendarManager()
    
    static func getSchedule(for date: Date, completion: @escaping ([Shift]) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/schedule/day/\(DateUtils.getDateComponent(date, .year))/\(DateUtils.getDateComponent(date, .month))/\(DateUtils.getDateComponent(date, .day))", token: AuthManager.shared.token) { (res: Result<[Shift], NetworkError>) in
            switch res {
            case .failure(_):
                completion([])
            case .success(let schedule):
                completion(schedule)
            }
        }
    }
    
    static func getWeekSchedule(year: Int, week: Int, completion: @escaping ([Date: [Shift]]) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/schedule/week/\(year)/\(week)", token: AuthManager.shared.token) { (res: Result<[Shift], NetworkError>) in
            switch res {
            case .failure(_):
                completion([:])
            case .success(let schedule):
                completion(Dictionary(grouping: schedule) { Calendar.current.startOfDay(for: $0.start) })
            }
        }
    }
    
    static func editShift(id: String, start: Date, end: Date?, canceled: Bool, completion: @escaping (Shift?) -> Void) {
        struct _Shift: Codable {
            var start: Date
            var end: Date?
            var canceled: Bool
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
                formatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")

                let formattedStart = formatter.string(from: start)
                try container.encode(formattedStart, forKey: .start)

                if let end = end {
                    let formattedEnd = formatter.string(from: end)
                    try container.encode(formattedEnd, forKey: .end)
                }
                
                try container.encode(canceled, forKey: .canceled)
            }

            enum CodingKeys: String, CodingKey {
                case start
                case end
                case canceled
            }
        }
        
        Requests.patch(url: AuthManager.serverUrl + "/schedule/shift/" + id, token: AuthManager.shared.token, data: _Shift(start: start, end: end, canceled: canceled)) { (res: Result<Shift, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let shift):
                completion(shift)
            }
        }
    }
    
    static func parse(_ image: Data, completion: @escaping (Bool) -> Void) {
        struct _ImageData: Codable {
            var image: String
        }
        
        Requests.post(url: AuthManager.serverUrl + "/schedule", token: AuthManager.shared.token, data: _ImageData(image: image.base64EncodedString())) { (res: Result<[Shift], NetworkError>) in
            switch res {
            case .success(_):
                return completion(true)

            case .failure(let error):
                completion(error == .invalidData)
            }
        }
    }
}

enum ParseError: Error {
    case invalidSchedule
}
