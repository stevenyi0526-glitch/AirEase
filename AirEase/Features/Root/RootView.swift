//
//  RootView.swift
//  AirEase
//
//  根视图 - 控制导航流程
//

import SwiftUI

struct RootView: View {
    @StateObject private var persistence = PersistenceService.shared
    @State private var showSplash = true
    @State private var isOnboardingComplete: Bool
    
    init() {
        // Initialize from persisted state
        _isOnboardingComplete = State(initialValue: UserDefaults.standard.bool(forKey: Constants.StorageKeys.didOnboard))
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(isActive: $showSplash)
                    .transition(.opacity)
            } else if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            } else {
                SearchHomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSplash)
        .animation(.easeInOut(duration: 0.3), value: isOnboardingComplete)
    }
}

// MARK: - Preview
#Preview {
    RootView()
}
