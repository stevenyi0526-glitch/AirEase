//
//  Constants.swift
//  AirEase
//
//  App Constants
//

import Foundation
import SwiftUI

enum Constants {
    // MARK: - App Info
    enum App {
        static let name = "AirEase"
        static let displayName = "AirEase - Flight Experience"
        static let slogan = "Best Flight Experience"
        static let version = "1.0.0"
    }
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color("AccentColor")
        static let scoreExcellent = Color(red: 0.133, green: 0.773, blue: 0.369)    // #22C55E
        static let scoreGood = Color(red: 0.231, green: 0.510, blue: 0.965)          // #3B82F6
        static let scoreFair = Color(red: 0.961, green: 0.620, blue: 0.043)          // #F59E0B
        static let scorePoor = Color(red: 0.420, green: 0.451, blue: 0.498)          // #6B7280
        
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    }
    
    // MARK: - Layout
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let cardShadowRadius: CGFloat = 4
    }
    
    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let splashDuration: Double = 1.5
    }
    
    // MARK: - Cabin Types
    enum Cabin {
        static let economy = "Economy"
        static let business = "Business"
        static let first = "First Class"
        
        static let allCabins = [economy, business, first]
    }
    
    // MARK: - Cities (MVP static list)
    enum Cities {
        static let popular: [String] = [
            "Beijing", "Shanghai", "Guangzhou", "Shenzhen", "Chengdu",
            "Hangzhou", "Wuhan", "Xi'an", "Chongqing", "Nanjing",
            "Tianjin", "Suzhou", "Changsha", "Zhengzhou", "Qingdao"
        ]
        
        static let cityToCode: [String: String] = [
            "Beijing": "PEK",
            "Shanghai": "SHA",
            "Guangzhou": "CAN",
            "Shenzhen": "SZX",
            "Chengdu": "CTU",
            "Hangzhou": "HGH",
            "Wuhan": "WUH",
            "Xi'an": "XIY",
            "Chongqing": "CKG",
            "Nanjing": "NKG",
            "Tianjin": "TSN",
            "Suzhou": "SZV",
            "Changsha": "CSX",
            "Zhengzhou": "CGO",
            "Qingdao": "TAO"
        ]
    }
    
    // MARK: - Airlines
    enum Airlines {
        static let codeToName: [String: String] = [
            "CA": "Air China",
            "MU": "China Eastern",
            "CZ": "China Southern",
            "HU": "Hainan Airlines",
            "3U": "Sichuan Airlines",
            "ZH": "Shenzhen Airlines",
            "MF": "Xiamen Airlines",
            "FM": "Shanghai Airlines",
            "SC": "Shandong Airlines",
            "GS": "Tianjin Airlines"
        ]
    }
    
    // MARK: - Storage Keys
    enum StorageKeys {
        static let didOnboard = "didOnboard"
        static let userPersona = "userPersona"
        static let recentSearches = "recentSearches"
        static let favorites = "favorites"
        static let appLanguage = "appLanguage"
    }
    
    // MARK: - Limits
    enum Limits {
        static let maxRecentSearches = 3
        static let maxHighlights = 3
    }
}
