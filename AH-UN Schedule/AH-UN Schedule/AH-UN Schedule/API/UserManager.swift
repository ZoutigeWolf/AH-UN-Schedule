//
//  UserManager.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 28/03/2024.
//

import Foundation

class UserManager {
    static func getUser(username: String, completion: @escaping (User?) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/users/" + username, token: AuthManager.shared.token) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let user):
                completion(user)
            }
        }
    }
    
    static func getUsers(completion: @escaping ([User]) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/users", token: AuthManager.shared.token) { (res: Result<[User], NetworkError>) in
            switch res {
            case .failure(_):
                completion([])
            case .success(let users):
                completion(users)
            }
        }
    }
    
    static func createUser(username: String, scheduleName: String, email: String, isFulltime: Bool, completion: @escaping (User?) -> Void) {
        struct _UserData: Codable {
            var username: String
            var scheduleName: String
            var email: String
            var isFulltime: Bool
        }
        
        Requests.post(url: AuthManager.serverUrl + "/users", token: AuthManager.shared.token, data: _UserData(username: username, scheduleName: scheduleName, email: email, isFulltime: isFulltime)) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let user):
                completion(user)
            }
        }
    }
    
    static func editUser(id: UUID, username: String? = nil, scheduleName: String? = nil, email: String? = nil, isFulltime: Bool? = nil, isAdmin: Bool? = nil, completion: @escaping (User?) -> Void) {
        struct _UserData: Codable {
            var username: String?
            var scheduleName: String?
            var email: String?
            var isFulltime: Bool?
            var isAdmin: Bool?
        }
        
        Requests.put(url: AuthManager.serverUrl + "/users", token: AuthManager.shared.token, data: _UserData(username: username, scheduleName: scheduleName, email: email, isFulltime: isFulltime, isAdmin: isAdmin)) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let user):
                completion(user)
            }
        }
    }
    
    static func deleteUser(id: UUID, completion: @escaping (Bool) -> Void) {
        Requests.delete(url: AuthManager.serverUrl + "/users/" + id.uuidString, token: AuthManager.shared.token) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(let error):
                completion(error == .noData)
            case .success(_):
                completion(true)
            }
        }
    }
}
