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
            

            if AuthManager.shared.user!.admin {
                Section {
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
