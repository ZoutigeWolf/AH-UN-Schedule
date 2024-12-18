//
//  StatBox.swift
//  AH-UN Schedule
//
//  Created by ZoutigeWolf on 17/03/2024.
//

import SwiftUI

struct StatBox: View {
    let label: Text
    let value: Text
    let size: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            value
                .font(.system(size: 32))
                .padding(.bottom, 8)
    
            label
                .foregroundStyle(.secondary)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(width: size, height: 128)
        .background(Color(uiColor: UIColor.systemGray6))
        .cornerRadius(6)
    }
}

#Preview {
    StatBox(label: Text("Estimated earnings"), value: Text(1420.69, format: .currency(code: "EUR")), size: 160)
}
