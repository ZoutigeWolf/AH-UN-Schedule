//
//  UsersView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 21/03/2024.
//

import SwiftUI

struct UsersView: View {
    @State var users: [User] = []
    
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            if isLoading && users.count == 0 {
                ProgressView()
            }
            
            List {
                ForEach(users, id: \.username) { user in
                    NavigationLink(destination: EditUserView(user: user)) {
                        HStack {
                            Text(user.username)
                            
                            if user.admin {
                                Image(systemName: "person.badge.key.fill")
                            }
                        }
                    }
                }
            }
            .id(UUID())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Users")
//                        .bold()
//                }
//                
//                ToolbarItem(placement: .confirmationAction) {
//                    NavigationLink(destination: EditUserView(user: User(name: "", token: "", isAdmin: false), isNew: true)) {
//                        Image(systemName: "plus")
//                    }
//                }
            }
            .onAppear {
                refresh()
            }
            .refreshable {
                refresh()
            }
        }
    }
    
    func refresh() {
        isLoading = true
        
        UserManager.getUsers() { users in
            DispatchQueue.main.async {
                self.users = users
                isLoading = false
            }
        }
    }
}

#Preview {
    UsersView()
}
