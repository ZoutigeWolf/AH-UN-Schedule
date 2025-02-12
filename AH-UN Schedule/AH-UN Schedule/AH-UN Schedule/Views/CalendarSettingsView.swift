//
//  CalendarSettingsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 07/01/2025.
//

import SwiftUI

struct CalendarSettingsView: View {
    @Binding var settings: Settings
    let onSave: () -> Void
    
    @State var eventTitle: String
    
    init(settings: Binding<Settings>, onSave: @escaping () -> Void) {
        self._settings = settings
        self.onSave = onSave
        
        _eventTitle = State(initialValue: settings.wrappedValue.calendarEventTitle)
    }
    
    var body: some View {
        List {
            Section(header: Text("Event title"), footer: Text("The title of the events in the published calendar.")) {
                TextField("Event title", text: $eventTitle)
                    .onChange(of: eventTitle) { newTitle in
                        settings.calendarEventTitle = newTitle
                    }
            }
            
            Section(header: Text("Calendar URL"), footer: Text("Use this URL to automatically update your own calendar.")) {
                Text(AuthManager.shared.calendarURL().absoluteString)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = AuthManager.serverUrl + "/schedule/calendar/" + Data(AuthManager.shared.user!.username.utf8).base64EncodedString()
                        }) {
                            Text("Copy To Clipboard")
                            Image(systemName: "doc.on.clipboard")
                        }
                    }
            }
            
            Button {
                UIApplication.shared.open(AuthManager.shared.calendarURL())
            } label: {
                Text("Add to calendar")
            }
        }
        .navigationTitle(Text("Calendar"))
        .onDisappear() {
            onSave()
        }
    }
}
