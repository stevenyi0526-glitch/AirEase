//
//  PriceHistory.swift
//  AirEase
//
//  价格历史模型
//

import Foundation

struct PriceHistory: Codable, Hashable {
    let flightId: String
    let points: [PricePoint]
    let currentPrice: Double
    let trend: PriceTrend
    
    var formattedCurrentPrice: String {
        return "¥\(Int(currentPrice))"
    }
    
    var trendDescription: String {
        switch trend {
        case .rising: return "上涨趋势"
        case .falling: return "下降趋势"
        case .stable: return "价格稳定"
        }
    }
    
    var trendDescriptionEN: String {
        switch trend {
        case .rising: return "Rising"
        case .falling: return "Falling"
        case .stable: return "Stable"
        }
    }
    
    var trendIcon: String {
        switch trend {
        case .rising: return "arrow.up.right"
        case .falling: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var minPrice: Double {
        return points.map { $0.price }.min() ?? currentPrice
    }
    
    var maxPrice: Double {
        return points.map { $0.price }.max() ?? currentPrice
    }
}

struct PricePoint: Codable, Identifiable, Hashable {
    var id: String { "\(dateString)-\(price)" }
    let date: Date
    let price: Double
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    // Custom coding keys to handle date as string in JSON
    enum CodingKeys: String, CodingKey {
        case date
        case price
    }
    
    init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode date as string first, then as Date
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.date = formatter.date(from: dateString) ?? Date()
        } else {
            self.date = try container.decode(Date.self, forKey: .date)
        }
        
        self.price = try container.decode(Double.self, forKey: .price)
    }
}

enum PriceTrend: String, Codable {
    case rising
    case falling
    case stable
}

// MARK: - Sample Data
extension PriceHistory {
    static let sample: PriceHistory = {
        let calendar = Calendar.current
        let today = Date()
        let basePrice = 1280.0
        
        // Create realistic price fluctuations showing a falling trend
        // Prices were higher a week ago and have been dropping
        let pricePattern: [Double] = [
            1420,  // 7 days ago - highest
            1385,  // 6 days ago - slight drop
            1410,  // 5 days ago - small bounce
            1350,  // 4 days ago - significant drop
            1320,  // 3 days ago - continued decline
            1295,  // 2 days ago - approaching current
            1280   // today - current price
        ]
        
        var points: [PricePoint] = []
        for i in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let price = pricePattern[6 - i]
            points.append(PricePoint(date: date, price: price))
        }
        
        return PriceHistory(
            flightId: "sample-1",
            points: points,
            currentPrice: basePrice,
            trend: .falling
        )
    }()
}
