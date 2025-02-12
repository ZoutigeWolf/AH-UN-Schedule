//
//  AccountSettingsView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 07/01/2025.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var settings: Settings
    let onSave: () -> Void
    
    @State var wage: Double
    
    let user = AuthManager.shared.user
    
    init(settings: Binding<Settings>, onSave: @escaping () -> Void) {
        self._settings = settings
        self.onSave = onSave
        
        _wage = State(initialValue: settings.wrappedValue.wage)
    }
    
    var body: some View {
        List {
            Section(header: Text("Wage"), footer: Text("Your wage is used to calculate your estimated salary.")) {
                Stepper(value: $wage, in: 1...100, step: 0.5) {
                    HStack(alignment: .bottom) {
                        Text(wage, format: .currency(code: "EUR"))
                        Text("/ hour")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 10))
                            .padding(.bottom, 3)
                    }
                }
                .onChange(of: wage) { newWage in
                    settings.wage = newWage
                }
                .keyboardType(.decimalPad)
            }
            
            Section(footer: Text("Logged in as: \(AuthManager.shared.user!.name)")) {
                NavigationLink(destination: ChangePasswordView(user: user!)) {
                    Text("Change Password")
                }
                
                Button(role: .destructive) {
                    AuthManager.shared.logout()
                } label: {
                    Text("Logout")
                }
            }
        }
        .navigationTitle(Text("Account"))
        .onDisappear() {
            onSave()
        }
    }
}
