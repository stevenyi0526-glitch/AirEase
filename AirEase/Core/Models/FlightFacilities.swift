//
//  FlightFacilities.swift
//  AirEase
//
//  Flight Facilities Model
//

import Foundation

struct FlightFacilities: Codable, Hashable {
    let hasWifi: Bool?
    let hasPower: Bool?
    let seatPitchInches: Int?
    let seatPitchCategory: String?
    let hasIFE: Bool?
    let ifeType: String?
    let mealIncluded: Bool?
    let mealType: String?
    
    // Helper computed properties for display
    var wifiStatus: FacilityStatus {
        guard let hasWifi = hasWifi else { return .unknown }
        return hasWifi ? .available : .unavailable
    }
    
    var powerStatus: FacilityStatus {
        guard let hasPower = hasPower else { return .unknown }
        return hasPower ? .available : .unavailable
    }
    
    var ifeStatus: FacilityStatus {
        guard let hasIFE = hasIFE else { return .unknown }
        return hasIFE ? .available : .unavailable
    }
    
    var mealStatus: FacilityStatus {
        guard let mealIncluded = mealIncluded else { return .unknown }
        return mealIncluded ? .available : .unavailable
    }
    
    var seatPitchDisplay: String {
        guard let inches = seatPitchInches else { return "Unknown" }
        let category = seatPitchCategory ?? ""
        return "\(inches) inches\(category.isEmpty ? "" : " (\(category))")"
    }
    
    var ifeDisplay: String {
        guard let hasIFE = hasIFE else { return "Unknown" }
        if !hasIFE { return "Not Available" }
        return ifeType ?? "Available"
    }
    
    var mealDisplay: String {
        guard let mealIncluded = mealIncluded else { return "Unknown" }
        if !mealIncluded { return "Not Included" }
        return mealType ?? "Included"
    }
    
    // MARK: - English Display Properties
    
    var wifiStatusEN: String {
        guard let hasWifi = hasWifi else { return "Unknown" }
        return hasWifi ? "Available" : "Not Available"
    }
    
    var powerStatusEN: String {
        guard let hasPower = hasPower else { return "Unknown" }
        return hasPower ? "Available" : "Not Available"
    }
    
    var seatPitchDisplayEN: String {
        guard let inches = seatPitchInches else { return "Unknown" }
        return "\(inches) inches"
    }
    
    var ifeDisplayEN: String {
        guard let hasIFE = hasIFE else { return "Unknown" }
        if !hasIFE { return "Not Available" }
        if let type = ifeType {
            switch type {
            case "个人屏幕": return "Personal Screen"
            case "共享屏幕": return "Shared Screen"
            default: return type
            }
        }
        return "Available"
    }
    
    var mealDisplayEN: String {
        guard let mealIncluded = mealIncluded else { return "Unknown" }
        if !mealIncluded { return "Not Included" }
        if let type = mealType {
            switch type {
            case "正餐": return "Full Meal"
            case "轻食": return "Light Meal"
            case "公务舱餐食": return "Business Class Meal"
            default: return type
            }
        }
        return "Included"
    }
}

enum FacilityStatus {
    case available
    case unavailable
    case unknown
    
    var iconName: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .unavailable: return "xmark.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var displayText: String {
        switch self {
        case .available: return "可用"
        case .unavailable: return "不可用"
        case .unknown: return "暂无信息"
        }
    }
}

// MARK: - Sample Data
extension FlightFacilities {
    static let sample = FlightFacilities(
        hasWifi: true,
        hasPower: true,
        seatPitchInches: 34,
        seatPitchCategory: "宽敞",
        hasIFE: true,
        ifeType: "个人屏幕",
        mealIncluded: true,
        mealType: "正餐"
    )
    
    static let partial = FlightFacilities(
        hasWifi: nil,
        hasPower: true,
        seatPitchInches: nil,
        seatPitchCategory: nil,
        hasIFE: false,
        ifeType: nil,
        mealIncluded: true,
        mealType: "轻食"
    )
}
