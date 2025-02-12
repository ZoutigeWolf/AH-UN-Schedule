//
//  Insight.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import Foundation

struct Insight: Codable {
    var days: Int
    var hours: Double
    var salary: Double
    var averageShiftLength: [Int: Double]
    var shifts: [Shift]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.days = try container.decode(Int.self, forKey: .days)
        self.hours = try container.decode(Double.self, forKey: .hours)
        self.salary = try container.decode(Double.self, forKey: .salary)
        self.averageShiftLength = try container.decode([Int: Double].self, forKey: .averageShiftLength)
        self.shifts = try container.decode([Shift].self, forKey: .shifts)
    }
    
    enum CodingKeys: String, CodingKey {
        case days = "days"
        case hours = "hours"
        case salary = "salary"
        case averageShiftLength = "average_shift_length"
        case shifts = "shifts"
    }
}
