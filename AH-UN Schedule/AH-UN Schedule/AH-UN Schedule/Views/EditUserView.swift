//
//  EditUserView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 22/03/2024.
//

import SwiftUI

import SwiftUI

struct EditUserView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let user: User
    
    @State private var admin: Bool
    
    init(user: User) {
        self.user = user
        
        self._admin = State(initialValue: user.admin)
    }

    var body: some View {
        List {
            Section(header: Text("Username")) {
                Text(user.username)
            }
            
            Section(header: Text("Name")) {
                Text(user.name)
            }
            
            if AuthManager.shared.user!.admin {
                Section {
                    Toggle(isOn: $admin) {
                        Text("Admin")
                    }
                }
            }
            
            Section(header: Text("Calendar URL")) {
                Text(AuthManager.shared.calendarURL(user: user).absoluteString)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = AuthManager.shared.calendarURL(user: user).absoluteString
                        }) {
                            Text("Copy To Clipboard")
                            Image(systemName: "doc.on.clipboard")
                        }
                    }
            }
            

            if AuthManager.shared.user!.admin {
                Section(header: Text("Danger Zone")) {
                    NavigationLink(destination: ChangePasswordView(user: user)) {
                        Text("Change Password")
                    }
                    .disabled(AuthManager.shared.user!.username == user.username)
                    
                    Button(role: .destructive) {
                        delete()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Delete user")
                    }
                    .disabled(AuthManager.shared.user!.username == user.username)
                }
            }
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
    }
    
    func save() {
        UserManager.editUser(username: user.username, admin: admin) { _ in }
    }
    
    func delete() {
        UserManager.deleteUser(username: user.username) { _ in }
    }
}
