//
//  SearchQuery.swift
//  AirEase
//
//  Search Query Model
//

import Foundation

struct SearchQuery: Codable, Identifiable, Hashable {
    let id: UUID
    let fromCity: String
    let toCity: String
    let date: Date
    let cabin: String
    let timestamp: Date
    
    init(id: UUID = UUID(), fromCity: String, toCity: String, date: Date, cabin: String, timestamp: Date = Date()) {
        self.id = id
        self.fromCity = fromCity
        self.toCity = toCity
        self.date = date
        self.cabin = cabin
        self.timestamp = timestamp
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var displayText: String {
        return "\(fromCity) → \(toCity) · \(formattedDate)"
    }
    
    var shortDisplayText: String {
        return "\(fromCity) → \(toCity)"
    }
}

// MARK: - Sample Data
extension SearchQuery {
    static let sample = SearchQuery(
        fromCity: "Beijing",
        toCity: "Shanghai",
        date: Date(),
        cabin: "Economy"
    )
    
    static let samples: [SearchQuery] = [
        SearchQuery(fromCity: "Beijing", toCity: "Shanghai", date: Date(), cabin: "Economy"),
        SearchQuery(fromCity: "Guangzhou", toCity: "Chengdu", date: Date().addingTimeInterval(86400), cabin: "Business"),
        SearchQuery(fromCity: "Shenzhen", toCity: "Hangzhou", date: Date().addingTimeInterval(86400 * 2), cabin: "Economy")
    ]
}
