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
    let isNew: Bool
    
    @State private var username: String
    @State private var name: String
    @State private var admin: Bool
    
    init(user: User, isNew: Bool = false) {
        self.user = user
        self.isNew = isNew
        
        self._username = State(initialValue: user.username)
        self._name = State(initialValue: user.name)
        self._admin = State(initialValue: user.admin)
    }

    var body: some View {
        List {
            LabeledContent {
                TextField("Username", text: $username)
            } label: {
                Text("Username")
            }

            LabeledContent {
                TextField("Name", text: $name)
            } label: {
                Text("Schedule name")
            }

            if !isNew {
                Button(role: .destructive) {
                    delete()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Delete user")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text(user.name)
//                    .bold()
//            }
//            
//            ToolbarItem(placement: .confirmationAction) {
//                Button {
//                    save()
//                    presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Text("Done")
//                }
//            }
        }
    }
    
    func save() {
//        if isNew {
//            UserManager.createUser(username: username, scheduleName: scheduleName, email: email, isFulltime: isFulltime) { _ in }
//        } else {
//            UserManager.editUser(id: user.id, username: username, scheduleName: scheduleName, email: email, isFulltime: isFulltime, isAdmin: isAdmin) { _ in }
//        }
    }
    
    func delete() {
//        UserManager.deleteUser(id: user.id) { _ in }
    }
}
