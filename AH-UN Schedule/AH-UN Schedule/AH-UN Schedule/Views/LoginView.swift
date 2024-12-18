//
//  LoginView.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 27/03/2024.
//

import SwiftUI
import AVKit

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var backgroundPlayer: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "AHUN", withExtension: "mp4")!)
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showInvalidCredentialsAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 25)
                    .padding(.top, 25)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack {
                    VStack {
                        TextField("Username", text: self.$username)
                            .autocapitalization(.none)
                            .cornerRadius(4)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                    VStack {

                        SecureField("Password", text: self.$password)
                            .autocapitalization(.none)
                            .cornerRadius(4)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                }
                .textFieldStyle(.roundedBorder)
                
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .foregroundColor(self.colorScheme == .light ? .black : .white)
                        .padding(EdgeInsets(top: 10, leading: 45, bottom: 10, trailing: 45))
                }
                .background(self.colorScheme == .light ? .white : .black)
                .cornerRadius(4)
                .padding(.top, 25)
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .background(
            VideoPlayer(player: backgroundPlayer)
                .aspectRatio(CGSize(width: 32, height: 9), contentMode: .fill)
                .ignoresSafeArea(edges: .all)
                .onAppear {
                    backgroundPlayer.play()

                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                           object: backgroundPlayer.currentItem,
                                                           queue: .main) { _ in
                        backgroundPlayer.seek(to: .zero)
                        backgroundPlayer.play()
                    }
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self)
                }
                .disabled(true)
                .overlay(.black.opacity(0.55))
                .blur(radius: 5)
        )
        .alert(isPresented: $showInvalidCredentialsAlert) {
            Alert(
                title: Text("Login failed"),
                message: Text("Invalid username or password")
            )
        }
    }
    
    func login() {
        AuthManager.shared.login(username: username, password: password) { res in
            if !res {
                showInvalidCredentialsAlert = true
            }
        }
    }
}

#Preview {
    LoginView()
}
