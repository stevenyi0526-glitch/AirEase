//
//  AirEaseApp.swift
//  AirEase
//
//  Created by Steven Yi on 30/12/2025.
//

import SwiftUI

@main
struct AirEaseApp: App {
    
    init() {
        // Configure app settings
        configureApp()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
    
    private func configureApp() {
        // Set default configuration
        let config = AppConfiguration.shared
        
        // Enable mock data by default for MVP
        config.useMockData = true
        
        // Enable AI search feature flag (P1)
        config.enableAISearch = true
        
        // Log configuration in debug mode
        #if DEBUG
        print("🛫 AirEase Configuration:")
        print("   - Use Mock Data: \(config.useMockData)")
        print("   - Base URL: \(config.baseURL)")
        print("   - AI Search Enabled: \(config.enableAISearch)")
        #endif
    }
}
