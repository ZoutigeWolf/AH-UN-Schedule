//
//  Shift.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import Foundation

struct Shift: Codable {
    var id: String
    var username: String
    var start: Date
    var end: Date?
    var canceled: Bool
    var position: Position
    
    var user: User
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        
        let startDateString = try container.decode(String.self, forKey: .start)
        if let startDate = Date.fromString(startDateString, as: "yyyy-MM-dd'T'HH:mm:ss") {
            self.start = startDate
        } else {
            self.start = Date()
        }
        
        let endDateString = try container.decodeIfPresent(String.self, forKey: .end)
        if let endDate = Date.fromString(endDateString ?? "", as: "yyyy-MM-dd'T'HH:mm:ss") {
            self.end = endDate
        } else {
            self.end = nil
        }
        
        self.canceled = try container.decode(Bool.self, forKey: .canceled)
        
        self.position = .None
        
        self.user = try container.decode(User.self, forKey: .user)
    }
}

enum Position: String, Codable, Hashable, CaseIterable {
    case None   = "None"
    case Meat   = "Meat"
    case Dishes = "Dishes"
}
