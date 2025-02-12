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
    
    static func editUser(username: String, admin: Bool, completion: @escaping (User?) -> Void) {
        struct _UserData: Codable {
            var admin: Bool
        }
        
        Requests.patch(url: AuthManager.serverUrl + "/users/" + username, token: AuthManager.shared.token, data: _UserData(admin: admin)) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let user):
                completion(user)
            }
        }
    }
    
    static func editUserPassword(username: String, authPassword: String, newPassword: String, completion: @escaping (User?) -> Void) {
        struct _UserData: Codable {
            var auth_password: String
            var new_password: String
        }
        
        Requests.put(url: AuthManager.serverUrl + "/users/" + username + "/password", token: AuthManager.shared.token, data: _UserData(auth_password: authPassword, new_password: newPassword)) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let user):
                completion(user)
            }
        }
    }
    
    static func deleteUser(username: String, completion: @escaping (Bool) -> Void) {
        Requests.delete(url: AuthManager.serverUrl + "/users/" + username, token: AuthManager.shared.token) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(let error):
                completion(error == .noData)
            case .success(_):
                completion(true)
            }
        }
    }
    
    static func registerDevice(device: String, completion: @escaping (Bool) -> Void) {
        struct _DeviceInfo: Codable {
            var device: String
        }
        
        guard let username = AuthManager.shared.user?.username else {
            completion(false)
            return
        }
        
        Requests.post(url: AuthManager.serverUrl + "/users/" + username + "/devices", token: AuthManager.shared.token, data: _DeviceInfo(device: device)) { (res: Result<String, NetworkError>) in
            switch res {
            case .failure(_):
                completion(false)
            case .success(_):
                completion(true)
            }
        }
    }
    
    static func unregisterDevice(completion: @escaping (Bool) -> Void) {
        struct _DeviceInfo: Codable {
            var device: String
        }
        
        guard let username = AuthManager.shared.user?.username,
              let device = AuthManager.shared.deviceToken else {
            completion(false)
            return
        }
        
        Requests.delete(url: AuthManager.serverUrl + "/users/" + username + "/devices/" + device, token: AuthManager.shared.token) { (res: Result<String, NetworkError>) in
            switch res {
            case .failure(_):
                completion(false)
            case .success(_):
                completion(true)
            }
        }
    }
}
