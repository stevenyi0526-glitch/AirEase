//
//  FlightDetail.swift
//  AirEase
//
//  航班详情聚合模型
//

import Foundation

struct FlightDetail: Codable, Identifiable {
    var id: String { flight.id }
    
    let flight: Flight
    let score: FlightScore
    let facilities: FlightFacilities
    let priceHistory: PriceHistory
}

// MARK: - API Response Models
struct FlightSearchResponse: Codable {
    let flights: [FlightWithScore]
    let meta: SearchMeta
}

struct FlightWithScore: Codable, Identifiable {
    var id: String { flight.id }
    
    let flight: Flight
    let score: FlightScore
    let facilities: FlightFacilities
}

struct SearchMeta: Codable {
    let total: Int
    let searchId: String
    let cachedAt: Date?
}

// MARK: - Sample Data
extension FlightDetail {
    static let sample = FlightDetail(
        flight: .sample,
        score: .sample,
        facilities: .sample,
        priceHistory: .sample
    )
}

extension FlightWithScore {
    static let sample = FlightWithScore(
        flight: .sample,
        score: .sample,
        facilities: .sample
    )
}
