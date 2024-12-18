//
//  AuthModels.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 24/03/2024.
//

import Foundation

struct User: Codable {
    var username: String
    var name: String
    var admin: Bool
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.username = try container.decode(String.self, forKey: .username)
        self.name = try container.decode(String.self, forKey: .name)
        self.admin = try container.decode(Bool.self, forKey: .admin)
    }
}
