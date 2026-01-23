//
//  SplashView.swift
//  AirEase
//
//  Splash Screen
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var opacity: Double = 0
    @State private var scale: Double = 0.8
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
                .scaleEffect(scale)
            
            // App Name
            VStack(spacing: 8) {
                Text("AirEase")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                
                Text(Constants.App.slogan)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Tagline
            Text("Finding the best flight experience for you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 48)
        }
        .opacity(opacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Fade in animation
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                scale = 1
            }
            
            // Auto dismiss after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.splashDuration) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isActive = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView(isActive: .constant(true))
}
