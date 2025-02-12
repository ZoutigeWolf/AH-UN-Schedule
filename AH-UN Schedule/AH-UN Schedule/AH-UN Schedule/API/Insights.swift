//
//  Insights.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 17/03/2024.
//

import Foundation


final class Insights {
    static func getMonthlyStats(year: Int, month: Int, completion: @escaping (Insight?) -> Void) {
        Requests.get(url: AuthManager.serverUrl + "/insights/\(year)/\(month)", token: AuthManager.shared.token) { (res: Result<Insight, NetworkError>) in
            switch res {
            case .failure(_):
                completion(nil)
            case .success(let data):
                completion(data)
            }
        }
    }
}
