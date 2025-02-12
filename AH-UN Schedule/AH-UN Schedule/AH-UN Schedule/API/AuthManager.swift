//
//  AuthManager.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 21/03/2024.
//

import Foundation
import SwiftUI
import UserNotifications

class AuthManager: ObservableObject {
    public static let shared = AuthManager()
    
    static let serverUrl: String = "https://ah-un.zoutigewolf.dev"
//    static let serverUrl: String = "http://localhost:8000"
    
    @Published var user: User?
    var token: String?
    var deviceToken: String?
    
    init() {
        DispatchQueue.global().async {
            guard let (username, password) = self.loadCredentialFromKeychain() else {
                return
            }
            
            self.login(username: username, password: password) { res in
                if res {
                    print("Authenticated using keychain credentials")
                } else {
                    print("Failed to authenticate using keychain credentials")
                }
            }
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = Self.serverUrl + "/auth/login"
        
        struct _Credentials: Codable {
            var username: String
            var password: String
        }
        
        Requests.post(url: url, data: _Credentials(username: username, password: password)) { (res: Result<[String: String], NetworkError>) in
            switch res {
            case .failure(_):
                completion(false)
            case .success(let data):
                guard let token = data["token"] else {
                    completion(false)
                    return
                }
                
                self.token = token
                
                self.storeCredentialsInKeychain(username, password)
                
                self.getUser() { res in
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, err in
                        if granted {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                    
                    completion(res)
                }
            }
        }
    }
    
    func logout() {
        UserManager.unregisterDevice() { res in }
        
        self.user = nil
        self.token = nil
        self.deviceToken = nil
        
        deleteCredentialFromKeychain()
    }
    
    func calendarURL(user: User? = nil) -> URL {
        return URL(string: "webcal://ah-un.zoutigewolf.dev/schedule/calendar/" + Data(user?.username.utf8 ?? self.user!.username.utf8).base64EncodedString())!
    }
    
    private func getUser(completion: @escaping (Bool) -> Void) {
        let url = Self.serverUrl + "/auth/me"

        Requests.get(url: url, token: self.token) { (res: Result<User, NetworkError>) in
            switch res {
            case .failure(_):
                completion(false)
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                }
                completion(true)
            }
        }
    }
    
    private func storeCredentialsInKeychain(_ username: String, _ password: String) {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: password.data(using: .utf8)!,
            kSecAttrServer as String: Self.serverUrl
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
 
        if status == noErr {
            print("Saved credentials to keychain")
        } else if status == errSecDuplicateItem {
            self.updateCredentialsInKeychain(username, password)
        } else {
            print("Failed to save credentails to keychain \(status)")
        }
    }
    
    private func updateCredentialsInKeychain(_ username: String, _ password: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: Self.serverUrl
        ]
        
        let attributes: [String: Any] = [
            kSecAttrAccount as String: username,
            kSecValueData as String: password.data(using: .utf8)!
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
  
        if status == noErr {
            print("Updated keychain credentials")
        } else {
            print("Failed to update keychain credentials \(status)")
        }
    }
    
    private func loadCredentialFromKeychain() -> (String, String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: Self.serverUrl,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == noErr {
            if let i = item as? [String: Any],
               let username = i[kSecAttrAccount as String] as? String,
               let passwordData = i[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8), !password.isEmpty {
                print("Retrieved credentials from keychain")
                return (username, password)
            } else {
                print("Failed to retrieve credentials from keychain \(status)")
                return nil
            }
        }
        
        return nil
    }
    
    private func deleteCredentialFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: Self.serverUrl
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == noErr {
            print("Deleted credentials from keychain")
        } else {
            print("Failed to delete credentials from keychain \(status)")
        }
    }
}

struct Message: Decodable {
    let message: String
}
