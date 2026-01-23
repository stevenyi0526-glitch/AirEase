//
//  Extensions.swift
//  AirEase
//
//  通用扩展
//

import Foundation
import SwiftUI

// MARK: - Theme Colors
extension Color {
    /// AirEase Primary Purple (#5B4BFF)
    static let aireasePurple = Color(red: 0.357, green: 0.294, blue: 1.0)
    
    /// AirEase Dark Purple
    static let aireasePurpleDark = Color(red: 0.29, green: 0.22, blue: 0.85)
    
    /// AirEase Light Purple (for backgrounds)
    static let aireasePurpleLight = Color(red: 0.357, green: 0.294, blue: 1.0).opacity(0.1)
}

// MARK: - Date Extensions
extension Date {
    /// 格式化为 "M月d日"
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    /// 格式化为 "yyyy-MM-dd"
    var isoDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// 格式化为 "HH:mm"
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// 格式化为 "MM/dd"
    var shortMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }
    
    /// 格式化为英文长日期 "Wednesday, Jan 15, 2025"
    var formattedDateLong: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
    
    /// 格式化为英文短日期 "Jan 15"
    var formattedDateShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }
    
    /// 获取下周某天
    static func nextWeekday(_ weekday: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        
        var daysToAdd = weekday - todayWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7
        }
        
        return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
    }
}

// MARK: - String Extensions
extension String {
    /// 解析简单的日期关键词
    var parsedDate: Date? {
        let calendar = Calendar.current
        let today = Date()
        
        if self.contains("今天") {
            return today
        } else if self.contains("明天") {
            return calendar.date(byAdding: .day, value: 1, to: today)
        } else if self.contains("后天") {
            return calendar.date(byAdding: .day, value: 2, to: today)
        } else if self.contains("下周一") {
            return Date.nextWeekday(2)
        } else if self.contains("下周二") {
            return Date.nextWeekday(3)
        } else if self.contains("下周三") {
            return Date.nextWeekday(4)
        } else if self.contains("下周四") {
            return Date.nextWeekday(5)
        } else if self.contains("下周五") {
            return Date.nextWeekday(6)
        } else if self.contains("下周六") {
            return Date.nextWeekday(7)
        } else if self.contains("下周日") || self.contains("下周天") {
            return Date.nextWeekday(1)
        }
        
        return nil
    }
    
    /// 解析舱位关键词
    var parsedCabin: String? {
        if self.contains("头等") {
            return Constants.Cabin.first
        } else if self.contains("公务") || self.contains("商务") {
            return Constants.Cabin.business
        } else if self.contains("经济") {
            return Constants.Cabin.economy
        }
        return nil
    }
    
    /// 从文本中提取城市
    func extractCities() -> [String] {
        var found: [String] = []
        for city in Constants.Cities.popular {
            if self.contains(city) {
                found.append(city)
            }
        }
        return found
    }
}

// MARK: - View Extensions
extension View {
    /// 添加卡片样式
    func cardStyle() -> some View {
        self
            .background(Constants.Colors.background)
            .cornerRadius(Constants.Layout.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: Constants.Layout.cardShadowRadius, x: 0, y: 2)
    }
    
    /// 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions
extension Color {
    /// 从分数获取颜色
    static func scoreColor(for score: Double) -> Color {
        switch score {
        case 8.5...10.0:
            return Constants.Colors.scoreExcellent
        case 7.0..<8.5:
            return Constants.Colors.scoreGood
        case 5.0..<7.0:
            return Constants.Colors.scoreFair
        default:
            return Constants.Colors.scorePoor
        }
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    /// 更新或添加元素
    mutating func upsert(_ element: Element) {
        if let index = firstIndex(where: { $0.id as AnyObject === element.id as AnyObject }) {
            self[index] = element
        } else {
            append(element)
        }
    }
}
