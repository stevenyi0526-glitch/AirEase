//
//  AppConfiguration.swift
//  AirEase
//
//  应用配置 - 控制Mock/真实API切换
//

import Foundation

final class AppConfiguration {
    static let shared = AppConfiguration()
    
    private init() {}
    
    // MARK: - API Configuration
    
    /// 是否使用Mock数据 - 设为false时使用真实API
    var useMockData: Bool = true
    
    /// API基础URL - 仅在useMockData为false时使用
    var baseURL: String = "https://api.airease.com"
    
    /// API超时时间（秒）
    var apiTimeout: TimeInterval = 30
    
    // MARK: - Feature Flags
    
    /// 是否启用AI自然语言搜索（P1）
    var enableAISearch: Bool = false
    
    /// 是否启用PK对比功能（P2）
    var enablePKCompare: Bool = false
    
    /// 是否启用微信登录（P2）
    var enableWeChatLogin: Bool = false
    
    /// 是否启用价格监控（P2）
    var enablePriceMonitoring: Bool = false
    
    // MARK: - External API Keys (需要替换为真实值)
    
    /// 航班数据API密钥 (例如: Skyscanner, Amadeus, 或其他GDS)
    /// 在生产环境中，应从安全存储或环境变量读取
    var flightAPIKey: String = "YOUR_FLIGHT_API_KEY_HERE"
    
    /// 航班数据API Secret
    var flightAPISecret: String = "YOUR_FLIGHT_API_SECRET_HERE"
    
    /// 微信开放平台AppID
    var weChatAppID: String = "YOUR_WECHAT_APP_ID"
    
    /// 微信开放平台AppSecret
    var weChatAppSecret: String = "YOUR_WECHAT_APP_SECRET"
    
    // MARK: - API Endpoints
    
    var flightSearchEndpoint: String {
        return "\(baseURL)/v1/flights/search"
    }
    
    var flightDetailEndpoint: String {
        return "\(baseURL)/v1/flights"
    }
    
    var authEndpoint: String {
        return "\(baseURL)/v1/auth/wechat"
    }
    
    // MARK: - Debug
    
    var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
