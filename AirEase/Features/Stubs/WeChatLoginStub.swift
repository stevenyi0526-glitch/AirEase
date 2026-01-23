//
//  WeChatLoginStub.swift
//  AirEase
//
//  WeChat Login Placeholder - P2
//

import SwiftUI

struct WeChatLoginButton: View {
    @State private var showAlert = false
    
    var body: some View {
        Button(action: {
            showAlert = true
        }) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundColor(.white)
                Text("WeChat Login")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.green)
            .cornerRadius(12)
        }
        .alert("WeChat Login", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("WeChat login feature is under development. A guest account has been created for you.")
        }
    }
}

#Preview {
    WeChatLoginButton()
        .padding()
}
