//
//  PKCompareView.swift
//  AirEase
//
//  Flight Comparison Page - P2 Placeholder
//

import SwiftUI

struct PKCompareView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple.opacity(0.5))
            
            Text("Flight Comparison")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Support multi-flight comparison\nOne-tap sharing posters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Back") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PKCompareView()
    }
}
