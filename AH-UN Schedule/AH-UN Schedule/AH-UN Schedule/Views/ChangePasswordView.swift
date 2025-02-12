//
//  ChangePasswordView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 08/01/2025.
//

import SwiftUI

struct ChangePasswordView: View {
    let user: User
    
    @State var authPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    func isValid() -> Bool {
        return authPassword.count > 0
            && newPassword.count > 0
            && confirmPassword.count > 0
            && newPassword == confirmPassword
    }
    
    func submit() {
        UserManager.editUserPassword(username: user.username, authPassword: authPassword, newPassword: newPassword) { user in }
    }
    
    var body: some View {
        List {
            Section {
                SecureField("Your password", text: $authPassword)
            }
            
            Section(footer: Text(newPassword != confirmPassword ? "Passwords don't match" : "")) {
                SecureField("New password", text: $newPassword)
                SecureField("Confirm password", text: $confirmPassword)
            }
            
            Section {
                Button {
                    submit()
                } label: {
                    Text("Submit")
                }
                .disabled(!isValid())
            }
        }
        .navigationTitle(Text("Change Password"))
    }
}
