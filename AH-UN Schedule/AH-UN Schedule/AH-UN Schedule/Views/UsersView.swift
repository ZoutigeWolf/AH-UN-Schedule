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
            if isLoading && users.isEmpty {
                ProgressView()
            } else {
                List {
                    Section(header: Text("Admins")) {
                        ForEach(users.filter { $0.admin }.sorted(by: { $0.username < $1.username }), id: \.username) { user in
                            NavigationLink(destination: EditUserView(user: user)) {
                                HStack {
                                    Text(user.name)
                                }
                            }
                        }
                    }
                    
                    ForEach(users.filter { !$0.admin }.sorted(by: { $0.username < $1.username }), id: \.username) { user in
                        NavigationLink(destination: EditUserView(user: user)) {
                            HStack {
                                Text(user.name)
                            }
                        }
                    }
                }
                .navigationTitle("Users")
                .navigationBarTitleDisplayMode(.inline)
                .refreshable {
                    refresh()
                }
            }
        }
        .onAppear {
            refresh()
        }
    }
    
    func refresh() {
        isLoading = true
        UserManager.getUsers { users in
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
