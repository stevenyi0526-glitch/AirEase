//
//  LanguageManager.swift
//  AirEase
//
//  Language Manager - Default English, supports Chinese
//

import Foundation
import SwiftUI

// MARK: - Supported Languages
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case chinese = "zh"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .chinese: return "中文"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .chinese: return "🇨🇳"
        }
    }
}

// MARK: - Language Manager
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @AppStorage(Constants.StorageKeys.appLanguage) private var languageRaw: String = AppLanguage.english.rawValue
    
    @Published var currentLanguage: AppLanguage = .english
    
    private init() {
        currentLanguage = AppLanguage(rawValue: languageRaw) ?? .english
    }
    
    func setLanguage(_ language: AppLanguage) {
        languageRaw = language.rawValue
        currentLanguage = language
        objectWillChange.send()
    }
    
    var isEnglish: Bool {
        currentLanguage == .english
    }
    
    var isChinese: Bool {
        currentLanguage == .chinese
    }
}

// MARK: - Localized Strings
struct L10n {
    static var shared: LanguageManager { LanguageManager.shared }
    
    // MARK: - Common
    static var ok: String { shared.isEnglish ? "OK" : "确定" }
    static var cancel: String { shared.isEnglish ? "Cancel" : "取消" }
    static var save: String { shared.isEnglish ? "Save" : "保存" }
    static var done: String { shared.isEnglish ? "Done" : "完成" }
    static var back: String { shared.isEnglish ? "Back" : "返回" }
    static var next: String { shared.isEnglish ? "Next" : "下一步" }
    static var search: String { shared.isEnglish ? "Search" : "搜索" }
    static var loading: String { shared.isEnglish ? "Loading..." : "加载中..." }
    static var error: String { shared.isEnglish ? "Error" : "错误" }
    static var retry: String { shared.isEnglish ? "Retry" : "重试" }
    
    // MARK: - Onboarding
    static var onboardingTitle: String { shared.isEnglish ? "What type of traveler are you?" : "您是哪类旅行者？" }
    static var onboardingSubtitle: String { shared.isEnglish ? "We'll personalize your flight experience recommendations" : "我们将为您个性化推荐航班体验" }
    static var getStarted: String { shared.isEnglish ? "Get Started" : "开始使用" }
    
    // MARK: - Personas
    static func personaName(_ persona: UserPersona) -> String {
        switch persona {
        case .business:
            return shared.isEnglish ? "Business Traveler" : "商务精英"
        case .family:
            return shared.isEnglish ? "Family Traveler" : "亲子家庭"
        case .student:
            return shared.isEnglish ? "Student Saver" : "学生党"
        }
    }
    
    static func personaDescription(_ persona: UserPersona) -> String {
        switch persona {
        case .business:
            return shared.isEnglish ? "Efficient work, reliable schedules" : "高效办公，时刻准点"
        case .family:
            return shared.isEnglish ? "Kid-friendly, spacious seating" : "儿童友好，宽敞舒适"
        case .student:
            return shared.isEnglish ? "Best value for your money" : "省钱至上，性价比高"
        }
    }
    
    // MARK: - Search
    static var searchFlights: String { shared.isEnglish ? "Search Flights" : "搜索航班" }
    static var from: String { shared.isEnglish ? "From" : "出发" }
    static var to: String { shared.isEnglish ? "To" : "到达" }
    static var departureDate: String { shared.isEnglish ? "Departure Date" : "出发日期" }
    static var cabin: String { shared.isEnglish ? "Cabin" : "舱位" }
    static var economy: String { shared.isEnglish ? "Economy" : "经济舱" }
    static var business: String { shared.isEnglish ? "Business" : "公务舱" }
    static var first: String { shared.isEnglish ? "First" : "头等舱" }
    static var recentSearches: String { shared.isEnglish ? "Recent Searches" : "最近搜索" }
    static var popularRoutes: String { shared.isEnglish ? "Popular Routes" : "热门航线" }
    static var swapCities: String { shared.isEnglish ? "Swap cities" : "交换城市" }
    
    // MARK: - Flight List
    static var flightsFound: String { shared.isEnglish ? "flights found" : "个航班" }
    static var sortBy: String { shared.isEnglish ? "Sort by" : "排序" }
    static var recommended: String { shared.isEnglish ? "Recommended" : "推荐" }
    static var priceLowToHigh: String { shared.isEnglish ? "Price: Low to High" : "价格升序" }
    static var priceHighToLow: String { shared.isEnglish ? "Price: High to Low" : "价格降序" }
    static var duration: String { shared.isEnglish ? "Duration" : "时长" }
    static var departureTime: String { shared.isEnglish ? "Departure Time" : "出发时间" }
    static var noFlightsFound: String { shared.isEnglish ? "No flights found" : "未找到航班" }
    
    // MARK: - Flight Detail
    static var flightDetails: String { shared.isEnglish ? "Flight Details" : "航班详情" }
    static var experienceScore: String { shared.isEnglish ? "Experience Score" : "体验评分" }
    static var overallScore: String { shared.isEnglish ? "Overall Score" : "综合评分" }
    static var whyThisScore: String { shared.isEnglish ? "Why This Score?" : "为什么是这个评分？" }
    static var highlights: String { shared.isEnglish ? "Highlights" : "亮点" }
    static var facilities: String { shared.isEnglish ? "Facilities" : "机上设施" }
    static var priceTrend: String { shared.isEnglish ? "Price Trend" : "价格趋势" }
    static var timeline: String { shared.isEnglish ? "Timeline" : "时间线" }
    static var bookNow: String { shared.isEnglish ? "Book Now" : "立即预订" }
    static var addToFavorites: String { shared.isEnglish ? "Add to Favorites" : "添加收藏" }
    static var removeFromFavorites: String { shared.isEnglish ? "Remove from Favorites" : "取消收藏" }
    static var share: String { shared.isEnglish ? "Share" : "分享" }
    
    // MARK: - Facilities
    static var wifi: String { shared.isEnglish ? "WiFi" : "无线网络" }
    static var power: String { shared.isEnglish ? "Power Outlet" : "电源插座" }
    static var entertainment: String { shared.isEnglish ? "Entertainment" : "娱乐系统" }
    static var seatPitch: String { shared.isEnglish ? "Seat Pitch" : "座位间距" }
    static var meal: String { shared.isEnglish ? "Meal" : "餐食" }
    static var available: String { shared.isEnglish ? "Available" : "有" }
    static var notAvailable: String { shared.isEnglish ? "Not Available" : "无" }
    static var unknown: String { shared.isEnglish ? "Unknown" : "未知" }
    
    // MARK: - Score Dimensions
    static var comfort: String { shared.isEnglish ? "Comfort" : "舒适度" }
    static var punctuality: String { shared.isEnglish ? "Punctuality" : "准点率" }
    static var service: String { shared.isEnglish ? "Service" : "服务" }
    static var entertainment_dim: String { shared.isEnglish ? "Entertainment" : "娱乐" }
    static var value: String { shared.isEnglish ? "Value" : "性价比" }
    
    // MARK: - Price
    static var currentPrice: String { shared.isEnglish ? "Current Price" : "当前价格" }
    static var priceDropping: String { shared.isEnglish ? "Price Dropping" : "价格下降" }
    static var priceRising: String { shared.isEnglish ? "Price Rising" : "价格上涨" }
    static var priceStable: String { shared.isEnglish ? "Price Stable" : "价格稳定" }
    static var goodTimeToBuy: String { shared.isEnglish ? "Good time to buy!" : "适合购买！" }
    static var mayDropMore: String { shared.isEnglish ? "May drop more, wait?" : "可能继续降，观望？" }
    static var buyBeforeRise: String { shared.isEnglish ? "Buy before it rises!" : "趁早入手！" }
    static var last7Days: String { shared.isEnglish ? "Last 7 Days" : "近7天" }
    
    // MARK: - Timeline
    static var departure: String { shared.isEnglish ? "Departure" : "起飞" }
    static var arrival: String { shared.isEnglish ? "Arrival" : "降落" }
    static var flightDuration: String { shared.isEnglish ? "Flight Duration" : "飞行时长" }
    static var nonstop: String { shared.isEnglish ? "Nonstop" : "直飞" }
    static var stop: String { shared.isEnglish ? "stop" : "经停" }
    static var stops: String { shared.isEnglish ? "stops" : "经停" }
    
    // MARK: - Settings
    static var settings: String { shared.isEnglish ? "Settings" : "设置" }
    static var language: String { shared.isEnglish ? "Language" : "语言" }
    static var selectLanguage: String { shared.isEnglish ? "Select Language" : "选择语言" }
    static var about: String { shared.isEnglish ? "About" : "关于" }
    static var version: String { shared.isEnglish ? "Version" : "版本" }
    
    // MARK: - Errors
    static var networkError: String { shared.isEnglish ? "Network error. Please try again." : "网络错误，请重试" }
    static var noResults: String { shared.isEnglish ? "No results found" : "未找到结果" }
    
    // MARK: - AI Search
    static var aiSearchPlaceholder: String { shared.isEnglish ? "Try: \"Flight to Shanghai next Friday\"" : "试试：下周五去上海的航班" }
    static var aiSearching: String { shared.isEnglish ? "AI is searching..." : "AI搜索中..." }
}
