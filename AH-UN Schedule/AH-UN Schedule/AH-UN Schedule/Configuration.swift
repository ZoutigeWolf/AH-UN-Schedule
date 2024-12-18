//
//  Configuration.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 16/03/2024.
//

import Foundation
import EventKit

final class Configuration {
    static var enableCalendar: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "enableCalendar")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "enableCalendar")
        }
    }
    
    static var selectedCalendar: String? {
        get {
            return UserDefaults.standard.string(forKey: "selectedCalendar")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "selectedCalendar")
        }
    }
    
    static var eventTitle: String {
        get {
            return UserDefaults.standard.string(forKey: "eventTitle") ?? "Work"
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "eventTitle")
        }
    }
    
    static var dishesNotation: String {
        get {
            return UserDefaults.standard.string(forKey: "dishesNotation") ?? "Dishes"
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "dishesNotation")
        }
    }
    
    static var meatNotation: String {
        get {
            return UserDefaults.standard.string(forKey: "meatNotation") ?? "Meat"
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "meatNotation")
        }
    }
    
    static var wage: Double {
        get {
            return UserDefaults.standard.double(forKey: "wage")
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "wage")
        }
    }
    
    static var shiftEventIdentifiers: [String: String] {
        get {
            return UserDefaults.standard.object(forKey: "shift-event-identifiers") as? [String: String] ?? [:]
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: "shift-event-identifiers")
        }
    }
}
