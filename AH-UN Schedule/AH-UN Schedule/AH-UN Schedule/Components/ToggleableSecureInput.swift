//
//  ToggleableSecureInput.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 21/03/2024.
//

import SwiftUI

struct ToggleableSecureInput: View {
    let title: String
    @Binding var text: String
    
    @State private var isSecured: Bool = true
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }.padding(.trailing, 32)

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
