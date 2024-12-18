//
//  CalendarManager.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 16/03/2024.
//

import Foundation
import EventKit

class CalendarManager {
    private let store = EKEventStore()
    
    static let positions = [
        Position.Dishes: Configuration.dishesNotation,
        Position.Meat: Configuration.meatNotation,
    ]
    
    init() {
        store.requestFullAccessToEvents() { granted, error in
            return
        }
    }
    
    var calendars: [EKCalendar] {
        return store.calendars(for: .event).filter { $0.allowsContentModifications }
    }
    
    func getCalendar(_ id: String?) -> EKCalendar? {
        return calendars.first { $0.calendarIdentifier == id }
    }
    
    func checkExistingEvents(_ event: EKEvent) {
        guard let calendar = getCalendar(Configuration.selectedCalendar) else {
            return
        }
        
        let events = store.events(matching: store.predicateForEvents(withStart: event.startDate, end: event.endDate, calendars: [calendar]))
        
        for event in events {
            try? store.remove(event, span: .thisEvent)
        }
    }
    
    func addToCalendar(shift: Shift) {
        let event = EKEvent(eventStore: self.store)

        guard let calendar = getCalendar(Configuration.selectedCalendar) else {
            return
        }
        
        event.calendar = calendar
        
        event.title = Configuration.eventTitle
        
        if shift.position != Position.None {
            event.title = "\(event.title!) (\(Self.positions[shift.position]!))"
        }
        
        event.startDate = shift.start
        
        event.endDate = shift.end ?? DateUtils.editDate(shift.start, hour: 22, minutes: 0)
        
        event.timeZone = TimeZone(identifier: "Europe/Amsterdam")

        event.location = "AH-UN Calypso"
        
        checkExistingEvents(event)
        
        _ = try? store.save(event, span: .thisEvent)
        
        Configuration.shiftEventIdentifiers[shift.id] = event.eventIdentifier
        
        
    }
    
    func updateEvent(_ shift: Shift) {
        guard let identifier = Configuration.shiftEventIdentifiers[shift.id] else {
            return
        }
        
        guard let event = store.event(withIdentifier: identifier) else {
            return
        }
        
        event.title = Configuration.eventTitle
        
        if shift.position != Position.None {
            event.title = "\(event.title!) (\(Self.positions[shift.position]!))"
        }
        
        event.startDate = shift.start
        
        event.endDate = shift.end ?? DateUtils.editDate(shift.start, hour: 22, minutes: 0)
        
        try? store.save(event, span: .thisEvent)
    }
}
