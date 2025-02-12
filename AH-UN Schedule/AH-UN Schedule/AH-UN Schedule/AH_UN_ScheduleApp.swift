//
//  AH_UN_ScheduleApp.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 14/03/2024.
//

import AVFoundation
import SwiftUI

@main
struct AH_UN_ScheduleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var authentication = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authentication.user == nil {
                LoginView()
            } else {
                HomeView()
            }
        }
    }
}

struct HomeView: View {
    var body: some View {
        TabView {
            ScheduleView()
            .tabItem {
                Label("Schedule", systemImage: "calendar")
                    .foregroundStyle(.white)
            }
            
            InsightsView()
            .tabItem {
                Label("Insights", systemImage: "chart.bar.fill")
                    .foregroundStyle(.white)
            }
            
            if let user = AuthManager.shared.user, user.admin {
                UsersView()
                .tabItem {
                    Label("Users", systemImage: "person.2.badge.gearshape.fill")
                        .foregroundStyle(.white)
                }
            }
            
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
                    .foregroundStyle(.white)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio category")
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceTokenData: Data) {
        let token = deviceTokenData.map { String(format: "%02x", $0) }.joined()
        
        print("Device Token: \(token)")
        
        AuthManager.shared.deviceToken = token
        
        UserManager.registerDevice(device: token) { res in }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

#Preview {
    HomeView()
}
