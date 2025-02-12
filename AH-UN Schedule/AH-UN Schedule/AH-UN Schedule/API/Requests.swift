//
//  Requests.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 21/03/2024.
//

import Foundation

class Requests {
    static func get<T: Decodable>(url: String, token: String? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        makeRequest(url: url, method: .GET, token: token, returnType: T.self, completion: completion)
    }
    
    static func post<T: Decodable>(url: String, token: String?  = nil, data: Encodable, completion: @escaping (Result<T, NetworkError>) -> Void) {
        makeRequest(url: url, method: .POST, token: token, data: data, returnType: T.self, completion: completion)
    }
    
    static func put<T: Decodable>(url: String, token: String?  = nil, data: Encodable, completion: @escaping (Result<T, NetworkError>) -> Void) {
        makeRequest(url: url, method: .PUT, token: token, data: data, returnType: T.self, completion: completion)
    }
    
    static func patch<T: Decodable>(url: String, token: String?  = nil, data: Encodable, completion: @escaping (Result<T, NetworkError>) -> Void) {
        makeRequest(url: url, method: .PATCH, token: token, data: data, returnType: T.self, completion: completion)
    }
    
    static func delete<T: Decodable>(url: String, token: String?  = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        makeRequest(url: url, method: .DELETE, token: token, returnType: T.self, completion: completion)
    }
    
    private static func makeRequest<T: Decodable>(url: String, method: HTTPMethod, token: String?, data: Encodable? = nil, returnType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        print(method.rawValue, url)
        guard let url = URL(string: url) else {
            print("Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        if let data = data,
           let jsonData = try? jsonEncoder.encode(data) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            print(String(data: jsonData, encoding: .utf8)!)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(method.rawValue, "Unsuccessful request", (response as? HTTPURLResponse)?.statusCode ?? 0)
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                print("No data")
                completion(.failure(.noData))
                return
            }
            
            do {
                let userResponse = try JSONDecoder().decode(T.self, from: data)
                print(method.rawValue, "Sucess", httpResponse.statusCode)
                completion(.success(userResponse))
            } catch {
                print("Invalid JSON data")
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

enum NetworkError: Error {
    case invalidURL,
         requestFailed,
         noData,
         invalidData,
         invalidImage,
         invalidToken
}
